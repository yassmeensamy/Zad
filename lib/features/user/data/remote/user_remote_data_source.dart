import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile();
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
}
