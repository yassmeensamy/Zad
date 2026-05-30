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
  }) : _remoteDataSource = remoteDataSource;

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<List<CategoryModel>> getCategories() =>
      _remoteDataSource.getCategories();

  @override
  Future<void> resetCategory(int categoryId) =>
      _remoteDataSource.resetCategory(categoryId);
}
