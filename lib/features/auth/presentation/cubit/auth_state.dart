import '../../core/auth_status.dart';
import '../../core/user_type.dart';

export '../../core/auth_status.dart';
export '../../core/user_type.dart';
export '../../data/models/social_provider.dart';

enum SocialAuthStatus { initial, loading, success, error }

extension SocialAuthStatusX on SocialAuthStatus {
  bool get isInitial => this == SocialAuthStatus.initial;
  bool get isLoading => this == SocialAuthStatus.loading;
  bool get isSuccess => this == SocialAuthStatus.success;
  bool get isError => this == SocialAuthStatus.error;
}

enum GuestAuthStatus { initial, loading, success, error }

extension GuestAuthStatusX on GuestAuthStatus {
  bool get isLoading => this == GuestAuthStatus.loading;
  bool get isSuccess => this == GuestAuthStatus.success;
  bool get isError => this == GuestAuthStatus.error;
}

enum VerificationStatus { pending, verifying, resending, error }

extension VerificationStatusX on VerificationStatus {
  bool get isPending => this == VerificationStatus.pending;
  bool get isVerifying => this == VerificationStatus.verifying;
  bool get isResending => this == VerificationStatus.resending;
  bool get isError => this == VerificationStatus.error;
}

enum UpgradeStatus { initial, loading, success, error }

extension UpgradeStatusX on UpgradeStatus {
  bool get isLoading => this == UpgradeStatus.loading;
  bool get isSuccess => this == UpgradeStatus.success;
  bool get isError => this == UpgradeStatus.error;
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.errorMessage,
    this.socialAuthStatus,
    this.userType,
    this.verificationStatus,
    this.pendingEmail,
    this.upgradeStatus,
    this.guestAuthStatus,
  });

  final AuthStatus status;
  final String? email;
  final String? errorMessage;
  final SocialAuthStatus? socialAuthStatus;
  final UserType? userType;

  final GuestAuthStatus? guestAuthStatus;

  final VerificationStatus? verificationStatus;

  final String? pendingEmail;

  final UpgradeStatus? upgradeStatus;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
    SocialAuthStatus? socialAuthStatus,
    UserType? userType,
    VerificationStatus? verificationStatus,
    String? pendingEmail,
    UpgradeStatus? upgradeStatus,
    GuestAuthStatus? guestAuthStatus,
  }) => AuthState(
    status: status ?? this.status,
    email: email ?? this.email,
    errorMessage: errorMessage,
    socialAuthStatus: socialAuthStatus,
    userType: userType ?? this.userType,
    verificationStatus: verificationStatus,
    pendingEmail: pendingEmail ?? this.pendingEmail,
    upgradeStatus: upgradeStatus,
    guestAuthStatus: guestAuthStatus,
  );

  bool get isInitial => status.isInitial;
  bool get isLoading => status.isLoading;
  bool get isLoggedIn => status.isLoggedIn;
  bool get isNotLoggedIn => status.isNotLoggedIn;
  bool get isError => status.isError;
  bool get isGuest => userType?.isGuest ?? status.isGuest;
  bool get isSocialLoading => socialAuthStatus?.isLoading ?? false;
  bool get isPendingVerification => verificationStatus?.isPending ?? false;
  bool get isVerifying => verificationStatus?.isVerifying ?? false;
  bool get isResendingCode => verificationStatus?.isResending ?? false;
  bool get isVerificationError => verificationStatus?.isError ?? false;
  bool get isAwaitingVerification => verificationStatus != null;
  bool get isUpgrading => upgradeStatus?.isLoading ?? false;
  bool get isUpgradeSuccess => upgradeStatus?.isSuccess ?? false;
  bool get isUpgradeError => upgradeStatus?.isError ?? false;
  bool get isGuestLoading => guestAuthStatus?.isLoading ?? false;
  bool get isGuestSuccess => guestAuthStatus?.isSuccess ?? false;
  bool get isGuestError => guestAuthStatus?.isError ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.email == email &&
        other.errorMessage == errorMessage &&
        other.socialAuthStatus == socialAuthStatus &&
        other.userType == userType &&
        other.verificationStatus == verificationStatus &&
        other.pendingEmail == pendingEmail &&
        other.upgradeStatus == upgradeStatus &&
        other.guestAuthStatus == guestAuthStatus;
  }

  @override
  int get hashCode => Object.hash(
    status,
    email,
    errorMessage,
    socialAuthStatus,
    userType,
    verificationStatus,
    pendingEmail,
    upgradeStatus,
    guestAuthStatus,
  );
}
