enum ForgotOtpStatus { initial, sending, sent, error }

enum ResetPasswordStatus { initial, resetting, success, error }

extension ForgotOtpStatusX on ForgotOtpStatus {
  bool get isInitial => this == ForgotOtpStatus.initial;
  bool get isSending => this == ForgotOtpStatus.sending;
  bool get isSent => this == ForgotOtpStatus.sent;
  bool get isError => this == ForgotOtpStatus.error;
}

extension ResetPasswordStatusX on ResetPasswordStatus {
  bool get isInitial => this == ResetPasswordStatus.initial;
  bool get isResetting => this == ResetPasswordStatus.resetting;
  bool get isSuccess => this == ResetPasswordStatus.success;
  bool get isError => this == ResetPasswordStatus.error;
}

class ForgotPasswordState {
  const ForgotPasswordState({
    this.otpStatus = ForgotOtpStatus.initial,
    this.resetStatus = ResetPasswordStatus.initial,
    this.email,
    this.errorMessage,
  });

  final ForgotOtpStatus otpStatus;
  final ResetPasswordStatus resetStatus;
  final String? email;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    ForgotOtpStatus? otpStatus,
    ResetPasswordStatus? resetStatus,
    String? email,
    String? errorMessage,
  }) => ForgotPasswordState(
    otpStatus: otpStatus ?? this.otpStatus,
    resetStatus: resetStatus ?? this.resetStatus,
    email: email ?? this.email,
    errorMessage: errorMessage,
  );

  bool get isSendingOtp => otpStatus.isSending;
  bool get isOtpSent => otpStatus.isSent;
  bool get isResetting => resetStatus.isResetting;
  bool get isSuccess => resetStatus.isSuccess;
  bool get isError => otpStatus.isError || resetStatus.isError;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForgotPasswordState &&
        other.otpStatus == otpStatus &&
        other.resetStatus == resetStatus &&
        other.email == email &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(otpStatus, resetStatus, email, errorMessage);
}
