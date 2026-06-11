enum AppStartupStatus { initial, loading, error, success }

extension AppStartupStateX on AppStartupState {
  bool get isInitial => status == AppStartupStatus.initial;
  bool get isLoading => status == AppStartupStatus.loading;
  bool get isSuccess => status == AppStartupStatus.success;
  bool get isError => status == AppStartupStatus.error;
}

class AppStartupState {
  const AppStartupState({
    required this.status,
    this.needsOnboarding = false,
    this.forceUpdateRequired = false,
    this.errorMessage,
  });

  final AppStartupStatus status;

  final bool needsOnboarding;

  /// True when the installed build is below the remote minimum and a blocking
  /// update dialog must be shown. Startup short-circuits when this is set.
  final bool forceUpdateRequired;
  final String? errorMessage;

  AppStartupState copyWith({
    AppStartupStatus? status,
    bool? needsOnboarding,
    bool? forceUpdateRequired,
    String? errorMessage,
  }) => AppStartupState(
    status: status ?? this.status,
    needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    forceUpdateRequired: forceUpdateRequired ?? this.forceUpdateRequired,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStartupState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          needsOnboarding == other.needsOnboarding &&
          forceUpdateRequired == other.forceUpdateRequired &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      Object.hash(status, needsOnboarding, forceUpdateRequired, errorMessage);
}
