import '../responses/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResponse> login({
    required String identifier,
    required String password,
  });

  Future<AuthResponse> loginWithGoogle();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<AuthResponse> switchAccount(String childId);

  Future<void> logout();

  Future<void> deleteAccount(String password);

  Future<String?> getAccessToken();

  Future<bool> isLoggedIn();
}
