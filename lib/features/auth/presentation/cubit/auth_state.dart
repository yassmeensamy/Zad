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

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.errorMessage,
    this.socialAuthStatus,
    this.userType,
  });

  final AuthStatus status;
  final String? email;
  final String? errorMessage;
  final SocialAuthStatus? socialAuthStatus;
  final UserType? userType;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
    SocialAuthStatus? socialAuthStatus,
    UserType? userType,
  }) => AuthState(
    status: status ?? this.status,
    email: email ?? this.email,
    errorMessage: errorMessage,
    socialAuthStatus: socialAuthStatus,
    userType: userType ?? this.userType,
  );

  bool get isInitial => status.isInitial;
  bool get isLoading => status.isLoading;
  bool get isLoggedIn => status.isLoggedIn;
  bool get isNotLoggedIn => status.isNotLoggedIn;
  bool get isError => status.isError;
  bool get isGuest => status.isGuest;
  bool get isSocialLoading => socialAuthStatus?.isLoading ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.email == email &&
        other.errorMessage == errorMessage &&
        other.socialAuthStatus == socialAuthStatus &&
        other.userType == userType;
  }

  @override
  int get hashCode =>
      Object.hash(status, email, errorMessage, socialAuthStatus, userType);
}
