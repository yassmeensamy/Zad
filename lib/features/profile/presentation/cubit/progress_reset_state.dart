enum ProgressResetStatus { idle, loading, success, error }

class ProgressResetState {
  const ProgressResetState({
    this.status = ProgressResetStatus.idle,
    this.errorMessage,
  });

  final ProgressResetStatus status;
  final String? errorMessage;

  ProgressResetState copyWith({
    ProgressResetStatus? status,
    String? Function()? errorMessage,
  }) => ProgressResetState(
    status: status ?? this.status,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressResetState &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, errorMessage);
}

extension ProgressResetStateX on ProgressResetState {
  bool get isLoading => status == ProgressResetStatus.loading;
  bool get isSuccess => status == ProgressResetStatus.success;
  bool get isError => status == ProgressResetStatus.error;
}
