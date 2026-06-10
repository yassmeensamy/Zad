import '../../../categories/data/models/category_model.dart';
import '../local/offline_content_dao.dart';
import '../remote/downloads_remote_data_source.dart';

typedef DownloadProgress = void Function(int fetched, int total);

abstract class DownloadsRepository {
  Future<void> downloadCategory(
    CategoryModel category, {
    DownloadProgress? onProgress,
  });
  Future<void> removeDownload(int categoryId);
  Future<bool> isDownloaded(int categoryId);
  Future<Set<int>> getDownloadedCategoryIds();
  Future<List<CategoryModel>> getDownloadedCategories();
}

class DownloadsRepositoryImpl implements DownloadsRepository {
  DownloadsRepositoryImpl({
    required DownloadsRemoteDataSource remote,
    required OfflineContentDao contentDao,
  }) : _remote = remote,
       _contentDao = contentDao;

  final DownloadsRemoteDataSource _remote;
  final OfflineContentDao _contentDao;

  @override
  Future<void> downloadCategory(
    CategoryModel category, {
    DownloadProgress? onProgress,
  }) async {
    onProgress?.call(0, 1);

    final bundle = await _remote.getCategoryDownload(category.id);

    await _contentDao.saveCategoryBundle(
      category: category,
      levels: bundle.levels,
      questionsByLevel: bundle.questionsByLevel,
    );

    onProgress?.call(1, 1);
  }

  @override
  Future<void> removeDownload(int categoryId) =>
      _contentDao.deleteCategory(categoryId);

  @override
  Future<bool> isDownloaded(int categoryId) =>
      _contentDao.isCategoryDownloaded(categoryId);

  @override
  Future<Set<int>> getDownloadedCategoryIds() =>
      _contentDao.getDownloadedCategoryIds();

  @override
  Future<List<CategoryModel>> getDownloadedCategories() =>
      _contentDao.getDownloadedCategories();
}
