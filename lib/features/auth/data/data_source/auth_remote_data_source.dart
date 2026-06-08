import '../responses/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResponse> login({
    required String identifier,
    required String password,
  });

  Future<AuthResponse> guestLogin();

  Future<AuthResponse> upgradeGuest({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResponse> googleAuth(String idToken);

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  });

  Future<void> resendVerification({required String email});

  Future<AuthResponse> switchAccount(String childId);

  Future<void> logout(String refreshToken);

  Future<void> deleteAccount(String password);
}
