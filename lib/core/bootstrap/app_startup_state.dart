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
    this.errorMessage,
  });

  final AppStartupStatus status;

  final bool needsOnboarding;
  final String? errorMessage;

  AppStartupState copyWith({
    AppStartupStatus? status,
    bool? needsOnboarding,
    String? errorMessage,
  }) => AppStartupState(
    status: status ?? this.status,
    needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStartupState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          needsOnboarding == other.needsOnboarding &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, needsOnboarding, errorMessage);
}
