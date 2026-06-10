import '../../../../core/api/network_failure.dart';
import '../../../offline/data/local/offline_content_dao.dart';
import '../models/level_model.dart';
import '../models/levels_response.dart';
import '../models/pagination.dart';
import '../remote/levels_remote_data_source.dart';

abstract class LevelsRepository {
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0});

  /// Resets the current user's progress for a single level.
  Future<void> resetLevel(int levelId);
}

class LevelsRepositoryImpl implements LevelsRepository {
  LevelsRepositoryImpl({
    required LevelsRemoteDataSource remoteDataSource,
    required OfflineContentDao contentDao,
  }) : _remoteDataSource = remoteDataSource,
       _contentDao = contentDao;

  final LevelsRemoteDataSource _remoteDataSource;
  final OfflineContentDao _contentDao;

  @override
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0}) async {
    try {
      return await _remoteDataSource.getLevels(categoryId, page: page);
    } catch (e) {
      if (isConnectivityError(e)) {
        return _offlineLevels(categoryId);
      }
      rethrow;
    }
  }

  /// Builds a single-page response from downloaded levels. `next` is null so
  /// `LevelsCubit.loadMore` stops paginating. Non-downloaded levels are absent.
  Future<LevelsResponse> _offlineLevels(int categoryId) async {
    final levels = await _contentDao.getDownloadedLevels(categoryId);
    final completed =
        levels.where((l) => l.status == LevelStatus.completed).length;
    return LevelsResponse(
      levels: levels,
      pagination: Pagination(page: 1, size: levels.length, total: levels.length),
      completedLevels: completed,
      totalLevels: levels.length,
    );
  }

  @override
  Future<void> resetLevel(int levelId) => _remoteDataSource.resetLevel(levelId);
}
