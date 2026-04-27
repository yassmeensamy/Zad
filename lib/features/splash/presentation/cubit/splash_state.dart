enum SplashDestination { onboarding, authCheck }

enum SplashStatus { initial, loading, error, success }

extension SplashStatesX on SplashStates {
  bool get isInitial => status == SplashStatus.initial;
  bool get isLoading => status == SplashStatus.loading;
  bool get isSuccess => status == SplashStatus.success;
  bool get isError => status == SplashStatus.error;
}

class SplashStates {
  const SplashStates({
    required this.status,
    this.destination,
    this.errorMessage,
  });

  final SplashStatus status;
  final SplashDestination? destination;
  final String? errorMessage;

  SplashStates copyWith({
    SplashStatus? status,
    SplashDestination? destination,
    String? errorMessage,
  }) => SplashStates(
    status: status ?? this.status,
    destination: destination ?? this.destination,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashStates &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          destination == other.destination &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, destination, errorMessage);
}
