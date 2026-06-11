import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  /// Resets the current user's progress for a single category.
  Future<void> resetCategory(int categoryId);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _networkService.get(_endpoints.quizCategories);
    response.validated();
    final list = response.data as List<dynamic>;
    final categories =
        list
            .map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return categories;
  }

  @override
  Future<void> resetCategory(int categoryId) async {
    final response = await _networkService.post(
      _endpoints.resetCategory(categoryId),
    );
    response.validated(const [200, 201, 204]);
  }
}
