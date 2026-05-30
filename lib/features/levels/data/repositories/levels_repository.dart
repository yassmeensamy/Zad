import '../models/levels_response.dart';
import '../remote/levels_remote_data_source.dart';

abstract class LevelsRepository {
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0});

  /// Resets the current user's progress for a single level.
  Future<void> resetLevel(int levelId);
}

class LevelsRepositoryImpl implements LevelsRepository {
  LevelsRepositoryImpl({required LevelsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final LevelsRemoteDataSource _remoteDataSource;

  @override
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0}) =>
      _remoteDataSource.getLevels(categoryId, page: page);

  @override
  Future<void> resetLevel(int levelId) => _remoteDataSource.resetLevel(levelId);
}
