import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/quran_sign_model.dart';

abstract class QuranSignRemoteDataSource {
  Future<QuranSignModel> getRandomSign();
}

class QuranSignRemoteDataSourceImpl implements QuranSignRemoteDataSource {
  QuranSignRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<QuranSignModel> getRandomSign() async {
    final response = await _networkService.get(_endpoints.randomQuranSign);
    response.validated();
    return QuranSignModel.fromMap(response.data as Map<String, dynamic>);
  }
}
