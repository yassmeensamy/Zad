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

  Future<AuthResponse> googleAuth(String idToken);

  Future<AuthResponse> switchAccount(String childId);

  Future<void> logout(String refreshToken);

  Future<void> deleteAccount(String password);
}
