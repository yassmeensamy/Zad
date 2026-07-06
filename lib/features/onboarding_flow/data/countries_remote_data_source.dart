import '../../../core/api/endpoints/app_endpoints.dart';
import '../../../core/api/network_service.dart';
import 'country_model.dart';

abstract class CountriesRemoteDataSource {
  Future<List<CountryModel>> getCountries();
}

class CountriesRemoteDataSourceImpl implements CountriesRemoteDataSource {
  CountriesRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _networkService.get(_endpoints.countries);
    response.validated();
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CountryModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
