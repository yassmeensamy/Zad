import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';

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

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

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
    _validateResponse(response);
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
    _validateResponse(response);
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> googleAuth(String idToken) async {
    final response = await _networkService.post(
      _endpoints.google,
      data: {'idToken': idToken},
      skipAuth: true,
    );
    _validateResponse(response);
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<AuthResponse> switchAccount(String childId) async {
    final response = await _networkService.post(
      _endpoints.switchAccount,
      data: {'childId': childId},
    );
    _validateResponse(response);
    return AuthResponse.fromMap(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    final response = await _networkService.post(
      _endpoints.logout,
      data: {'refreshToken': refreshToken},
    );
    _validateResponse(response, [200, 204]);
  }

  @override
  Future<void> deleteAccount(String password) async {
    final response = await _networkService.delete(
      _endpoints.me,
      data: {'password': password},
    );
    _validateResponse(response, [204]);
  }
}
