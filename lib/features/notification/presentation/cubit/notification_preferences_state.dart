import '../../data/models/notification_preferences.dart';

enum NotificationPreferencesStatus { initial, loading, loaded, error }

class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.status = NotificationPreferencesStatus.initial,
    this.preferences = const NotificationPreferences.empty(),
    this.enabled = false,
    this.permissionGranted = false,
    this.updating = false,
    this.errorMessage,
    this.actionError,
    this.permissionBlocked = false,
  });

  final NotificationPreferencesStatus status;

  /// Full per-type map kept so updates preserve untouched channels (in-app).
  final NotificationPreferences preferences;

  /// Master toggle value: push is on for at least one type *and* the OS grants
  /// the permission.
  final bool enabled;

  /// Whether the OS-level notification permission is currently granted.
  final bool permissionGranted;

  /// True while a toggle write is in flight; disables the switch.
  final bool updating;

  /// Message key for the full-area load failure.
  final String? errorMessage;

  /// One-shot message key for a failed toggle write, shown as a snackbar then
  /// cleared via [NotificationPreferencesCubit.clearActionError].
  final String? actionError;

  /// One-shot flag raised when the user tries to enable push but the OS
  /// permission is denied; the UI prompts them to open settings, then clears it
  /// via [NotificationPreferencesCubit.clearPermissionBlocked].
  final bool permissionBlocked;

  NotificationPreferencesState copyWith({
    NotificationPreferencesStatus? status,
    NotificationPreferences? preferences,
    bool? enabled,
    bool? permissionGranted,
    bool? updating,
    String? Function()? errorMessage,
    String? Function()? actionError,
    bool? permissionBlocked,
  }) => NotificationPreferencesState(
    status: status ?? this.status,
    preferences: preferences ?? this.preferences,
    enabled: enabled ?? this.enabled,
    permissionGranted: permissionGranted ?? this.permissionGranted,
    updating: updating ?? this.updating,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    actionError: actionError != null ? actionError() : this.actionError,
    permissionBlocked: permissionBlocked ?? this.permissionBlocked,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferencesState &&
        other.status == status &&
        other.preferences == preferences &&
        other.enabled == enabled &&
        other.permissionGranted == permissionGranted &&
        other.updating == updating &&
        other.errorMessage == errorMessage &&
        other.actionError == actionError &&
        other.permissionBlocked == permissionBlocked;
  }

  @override
  int get hashCode => Object.hash(
    status,
    preferences,
    enabled,
    permissionGranted,
    updating,
    errorMessage,
    actionError,
    permissionBlocked,
  );
}

extension NotificationPreferencesStateX on NotificationPreferencesState {
  bool get isInitial => status == NotificationPreferencesStatus.initial;
  bool get isLoading => status == NotificationPreferencesStatus.loading;
  bool get isLoaded => status == NotificationPreferencesStatus.loaded;
  bool get isError => status == NotificationPreferencesStatus.error;
}
