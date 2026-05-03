import '../models/level_model.dart';
import '../models/levels_response.dart';
import '../remote/levels_remote_data_source.dart';

abstract class LevelsRepository {
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0});
  List<LevelModel> getPlaceholders();
}

class LevelsRepositoryImpl implements LevelsRepository {
  LevelsRepositoryImpl({required LevelsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final LevelsRemoteDataSource _remoteDataSource;

  @override
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0}) =>
      _remoteDataSource.getLevels(categoryId, page: page);

  @override
  List<LevelModel> getPlaceholders() =>
      _remoteDataSource.getPlaceholders();
}
