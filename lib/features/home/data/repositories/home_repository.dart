import '../models/home_overview_model.dart';
import '../remote/home_remote_data_source.dart';

abstract class HomeRepository {
  Future<HomeOverviewModel> getOverview();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeOverviewModel> getOverview() => _remoteDataSource.getOverview();
}
