import '../../../../core/api/network_failure.dart';
import '../../../offline/data/local/offline_content_dao.dart';
import '../models/category_model.dart';
import '../remote/categories_remote_data_source.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();

  /// Resets the current user's progress for a single category.
  Future<void> resetCategory(int categoryId);
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({
    required CategoriesRemoteDataSource remoteDataSource,
    required OfflineContentDao contentDao,
  }) : _remoteDataSource = remoteDataSource,
       _contentDao = contentDao;

  final CategoriesRemoteDataSource _remoteDataSource;
  final OfflineContentDao _contentDao;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } catch (e) {
      // Offline: serve only the categories the user downloaded. Any other
      // failure (real server error) propagates unchanged.
      if (isConnectivityError(e)) {
        return _contentDao.getDownloadedCategories();
      }
      rethrow;
    }
  }

  @override
  Future<void> resetCategory(int categoryId) =>
      _remoteDataSource.resetCategory(categoryId);
}
