import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';

import '../responses/auth_response.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  const AuthRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  @override
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _networkService.post(
      _endpoints.signup,
      data: {'email': email, 'password': password, 'fullName': fullName},
      skipAuth: true,
    );
    response.validated(const [200, 201, 202]);
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _networkService.post(
      _endpoints.login,
      data: {'identifier': identifier, 'password': password},
      skipAuth: true,
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> guestLogin() async {
    final response = await _networkService.post(
      _endpoints.guestLogin,
      skipAuth: true,
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> upgradeGuest({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _networkService.post(
      _endpoints.upgradeGuest,
      data: {'email': email, 'password': password, 'fullName': fullName},
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> googleAuth(String idToken) async {
    final response = await _networkService.post(
      _endpoints.google,
      data: {'idToken': idToken},
      skipAuth: true,
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await _networkService.post(
      _endpoints.forgotPassword,
      data: {'email': email},
      skipAuth: true,
    );
    response.validated();
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _networkService.post(
      _endpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      skipAuth: true,
    );
    response.validated();
  }

  @override
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final response = await _networkService.post(
      _endpoints.verifyEmail,
      data: {'email': email, 'otp': otp},
      skipAuth: true,
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<void> resendVerification({required String email}) async {
    final response = await _networkService.post(
      _endpoints.resendVerification,
      data: {'email': email},
      skipAuth: true,
    );
    response.validated(const [200, 202]);
  }

  @override
  Future<AuthResponse> switchAccount(String childId) async {
    final response = await _networkService.post(
      _endpoints.switchAccount,
      data: {'childId': childId},
    );
    response.validated();
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    final response = await _networkService.post(
      _endpoints.logout,
      data: {'refreshToken': refreshToken},
    );
    response.validated([200, 204]);
  }

  @override
  Future<void> deleteAccount(String password) async {
    final response = await _networkService.delete(
      _endpoints.me,
      data: {'password': password},
    );
    response.validated([204]);
  }
}
