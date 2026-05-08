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

  Future<AuthResponse> switchAccount(String childId);

  Future<void> logout();

  Future<void> deleteAccount(String password);

  Future<String?> getAccessToken();

  Future<bool> isLoggedIn();
}
