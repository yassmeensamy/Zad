import '../models/category_model.dart';
import '../remote/categories_remote_data_source.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();
  List<CategoryModel> getPlaceholders();
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({required CategoriesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<List<CategoryModel>> getCategories() =>
      _remoteDataSource.getCategories();

  @override
  List<CategoryModel> getPlaceholders() =>
      _remoteDataSource.getPlaceholders();
}
