import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/app_notifiction_expection.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/services/permession_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/repositories/notification_preferences_repository.dart';
import 'notification_preferences_state.dart';

/// Drives the master "push notifications" toggle in the profile.
///
/// The switch reflects two facts at once: the OS permission (checked through
/// [PermissionService]) and the per-type push preferences (read/written via
/// [NotificationPreferencesRepository]). Enabling requires the OS permission;
/// when it is missing the cubit raises [NotificationPreferencesState.permissionBlocked]
/// so the UI can route the user to settings instead of silently failing.
class NotificationPreferencesCubit
    extends BaseCubit<NotificationPreferencesState> {
  NotificationPreferencesCubit({
    required NotificationPreferencesRepository repository,
    required PermissionService permissionService,
  }) : _repository = repository,
       _permissionService = permissionService,
       super(const NotificationPreferencesState());

  final NotificationPreferencesRepository _repository;
  final PermissionService _permissionService;

  /// Resolves the OS notification permission to a bool. [PermissionService]
  /// throws when the permission is denied/blocked, so we translate that into
  /// `false` rather than letting it bubble up.
  Future<bool> _isPermissionGranted() async {
    try {
      await _permissionService.checkNotificationPermission();
      return true;
    } on AppNotificationException {
      return false;
    } catch (e) {
      logger.debug('NotificationPreferencesCubit permission check failed: $e');
      return false;
    }
  }

  /// Loads the OS permission state and the saved preferences to seed the
  /// toggle. Called once when the switch mounts.
  Future<void> load() async {
    emit(state.copyWith(
      status: NotificationPreferencesStatus.loading,
      errorMessage: () => null,
    ));
    try {
      final granted = await _isPermissionGranted();
      final preferences = await _repository.getPreferences();
      emit(
        state.copyWith(
          status: NotificationPreferencesStatus.loaded,
          preferences: preferences,
          permissionGranted: granted,
          enabled: granted && preferences.anyEnabled,
        ),
      );
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: NotificationPreferencesStatus.error,
        errorMessage: () => e.message,
      ));
    } catch (e) {
      logger.error('NotificationPreferencesCubit.load failed: $e');
      emit(state.copyWith(
        status: NotificationPreferencesStatus.error,
        errorMessage: () => 'notifications.preferences_load_failed',
      ));
    }
  }

  /// Flips the master push toggle. Turning it on first verifies the OS grant
  /// (raising [permissionBlocked] if missing); the preference write is
  /// optimistic and rolls back on failure.
  Future<void> setEnabled(bool value) async {
    if (state.updating) return;

    if (value) {
      final granted = await _isPermissionGranted();
      if (!granted) {
        emit(state.copyWith(
          permissionGranted: false,
          enabled: false,
          permissionBlocked: true,
        ));
        return;
      }
      emit(state.copyWith(permissionGranted: true));
    }

    final previousPreferences = state.preferences;
    final previousEnabled = state.enabled;
    final updated = state.preferences.withAll(value);

    emit(state.copyWith(
      enabled: value,
      preferences: updated,
      updating: true,
      actionError: () => null,
    ));

    try {
      final saved = await _repository.updatePreferences(updated);
      emit(
        state.copyWith(
          preferences: saved,
          enabled: state.permissionGranted && saved.anyEnabled,
          updating: false,
        ),
      );
    } on ServerException catch (e) {
      _rollback(previousPreferences, previousEnabled, e.message);
    } catch (e) {
      logger.error('NotificationPreferencesCubit.setEnabled failed: $e');
      _rollback(
        previousPreferences,
        previousEnabled,
        'notifications.preferences_update_failed',
      );
    }
  }

  /// Opens the OS settings page when push is blocked at the system level.
  Future<void> openSystemSettings() => _permissionService.openSettings();

  void clearActionError() {
    if (state.actionError == null) return;
    emit(state.copyWith(actionError: () => null));
  }

  void clearPermissionBlocked() {
    if (!state.permissionBlocked) return;
    emit(state.copyWith(permissionBlocked: false));
  }

  void _rollback(
    NotificationPreferences previous,
    bool previousEnabled,
    String? message,
  ) {
    emit(state.copyWith(
      preferences: previous,
      enabled: previousEnabled,
      updating: false,
      actionError: () => message,
    ));
  }
}
