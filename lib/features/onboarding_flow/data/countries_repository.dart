import 'countries_remote_data_source.dart';
import 'country_model.dart';

abstract class CountriesRepository {
  Future<List<CountryModel>> getCountries();
}

class CountriesRepositoryImpl implements CountriesRepository {
  CountriesRepositoryImpl({required CountriesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CountriesRemoteDataSource _remoteDataSource;

  @override
  Future<List<CountryModel>> getCountries() => _remoteDataSource.getCountries();
}
