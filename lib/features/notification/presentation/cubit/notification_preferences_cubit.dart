import '../../../../core/cubits/base_cubit.dart';
import '../../../auth/core/auth_event_service.dart';
import '../../../auth/core/auth_state_listener_mixin.dart';
import '../../../../core/expections/app_notifiction_expection.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/services/permession_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/repositories/notification_preferences_repository.dart';
import 'notification_preferences_state.dart';

/// Drives the master "push notifications" toggle in the profile and the home
/// warning banner.
///
/// The switch reflects two facts at once: the OS permission (checked through
/// [PermissionService]) and the per-type push preferences (read/written via
/// [NotificationPreferencesRepository]). Enabling requires the OS permission;
/// when it is missing the cubit raises [NotificationPreferencesState.permissionBlocked]
/// so the UI can route the user to settings instead of silently failing.
///
/// Registered as a singleton and provided with `BlocProvider.value` so every
/// surface shares one instance: muting from the profile switch updates the home
/// banner immediately, and vice versa.
class NotificationPreferencesCubit
    extends BaseCubit<NotificationPreferencesState>
    with AuthStateListenerMixin {
  NotificationPreferencesCubit({
    required NotificationPreferencesRepository repository,
    required PermissionService permissionService,
    required AuthEventService authEventService,
  }) : _repository = repository,
       _permissionService = permissionService,
       _authEventService = authEventService,
       super(const NotificationPreferencesState()) {
    initAuthListener();
  }

  final NotificationPreferencesRepository _repository;
  final PermissionService _permissionService;
  final AuthEventService _authEventService;

  @override
  AuthEventService get authEventService => _authEventService;

  /// Preferences belong to the signed-in account, and this cubit outlives any
  /// screen — drop them on sign-out so the next session re-fetches instead of
  /// showing the previous user's state.
  @override
  void onUnauthenticated() => emit(const NotificationPreferencesState());

  @override
  Future<void> close() {
    disposeAuthListener();
    return super.close();
  }

  /// Set when we hand the user off to the OS settings page to grant a blocked
  /// permission. On the next app resume ([syncAfterResume]) it tells the cubit
  /// to finish the enable the user originally asked for.
  bool _enablePendingSettingsReturn = false;

  /// Guards [syncAfterResume]: the home banner and the profile switch both
  /// observe the lifecycle and share this cubit, so a single resume calls it
  /// twice — without this they'd double-fetch and race on the pending enable.
  bool _syncing = false;

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

  /// First-mount load for a shared instance: fetches only when nothing has been
  /// loaded yet, so a second surface (home banner + profile switch) attaching to
  /// the same cubit doesn't re-hit the API.
  Future<void> ensureLoaded() async {
    if (state.isInitial) await load();
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

  /// Opens the OS settings page when push is blocked at the system level. Marks
  /// the enable as pending so [syncAfterResume] can complete it once the user
  /// comes back with the permission granted.
  Future<void> openSystemSettings() {
    _enablePendingSettingsReturn = true;
    return _permissionService.openSettings();
  }

  /// Re-reconciles with the live OS permission *and* the server-side
  /// preferences when the app returns to the foreground. Called on app resume
  /// by the widgets.
  ///
  /// - If the user was sent to settings to enable push and the grant is now
  ///   present, the enable is finished automatically (no second tap needed).
  /// - Otherwise the state mirrors the current permission, so revoking it from
  ///   settings turns the toggle off / raises the home warning on return too.
  /// - The preferences are re-read either way, picking up a change made on
  ///   another device.
  Future<void> syncAfterResume() async {
    logger.debug(
      'syncAfterResume start: updating=${state.updating}, '
      'pending=$_enablePendingSettingsReturn, '
      'permissionGranted=${state.permissionGranted}',
    );
    // A write in flight will emit the authoritative state when it lands, and
    // nothing has loaded yet before the first [load].
    if (_syncing || state.updating || state.isInitial) return;
    _syncing = true;

    try {
      // A load that failed (offline at startup) gets a full retry instead of a
      // reconcile — there is no known-good state to reconcile against.
      if (state.isError) {
        await load();
        return;
      }

      final granted = await _isPermissionGranted();
      logger.debug('syncAfterResume: live permission granted=$granted');

      if (_enablePendingSettingsReturn) {
        _enablePendingSettingsReturn = false;
        if (granted) {
          logger.debug('syncAfterResume: finishing pending enable');
          emit(state.copyWith(permissionGranted: true));
          await setEnabled(true);
          return;
        }
        logger.debug('syncAfterResume: pending enable but still not granted');
      }

      if (granted != state.permissionGranted) {
        emit(state.copyWith(
          permissionGranted: granted,
          enabled: granted && state.preferences.anyEnabled,
        ));
      }
      await _refreshPreferencesQuietly();
    } finally {
      _syncing = false;
    }
  }

  /// Re-reads the saved preferences without touching [state.status], so a
  /// resume never flashes the UI back through a loading state. Failures are
  /// swallowed: the last known preferences stay on screen.
  Future<void> _refreshPreferencesQuietly() async {
    if (state.updating) return;
    try {
      final preferences = await _repository.getPreferences();
      if (preferences == state.preferences || state.updating) return;
      emit(state.copyWith(
        preferences: preferences,
        enabled: state.permissionGranted && preferences.anyEnabled,
      ));
    } catch (e) {
      logger.debug('NotificationPreferencesCubit quiet refresh failed: $e');
    }
  }

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
