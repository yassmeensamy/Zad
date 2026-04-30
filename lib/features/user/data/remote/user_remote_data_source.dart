import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<UserModel> getUserProfile() async {
    final response = await _networkService.get(_endpoints.me);
    if (response.statusCode != 200) {
      throw ServerException.fromMap(response.data);
    }
    return UserModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
  }) async {
    final response = await _networkService.put(
      _endpoints.me,
      data: {
        'fullName': fullName,
        'birthDate': birthDate?.toIso8601String(),
      },
    );
    if (response.statusCode != 200) {
      throw ServerException.fromMap(response.data);
    }
    return UserModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await _networkService.put(
      _endpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException.fromMap(response.data);
    }
  }
}
