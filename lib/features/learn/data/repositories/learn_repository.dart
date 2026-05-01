import '../models/learn_category.dart';
import '../remote/learn_remote_data_source.dart';

abstract class LearnRepository {
  Future<List<LearnCategory>> getCategories();
  Future<LearnCategory> getCategory(LearnCategoryId id);
  List<LearnCategory> getPlaceholders();
}

class LearnRepositoryImpl implements LearnRepository {
  LearnRepositoryImpl({required LearnRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final LearnRemoteDataSource _remoteDataSource;

  @override
  Future<List<LearnCategory>> getCategories() =>
      _remoteDataSource.getCategories();

  @override
  Future<LearnCategory> getCategory(LearnCategoryId id) =>
      _remoteDataSource.getCategory(id);

  @override
  List<LearnCategory> getPlaceholders() =>
      _remoteDataSource.getPlaceholders();
}
