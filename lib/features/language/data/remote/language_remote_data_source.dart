import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';

abstract class LanguageRemoteDataSource {
  Future<void> updateLanguage(String language);
}

class LanguageRemoteDataSourceImpl implements LanguageRemoteDataSource {
  LanguageRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<void> updateLanguage(String language) async {
    final response = await _networkService.put(
      _endpoints.userLanguage,
      data: {'language': language},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException.fromMap(response.data);
    }
  }
}
