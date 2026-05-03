import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  List<CategoryModel> getPlaceholders();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _networkService.get(_endpoints.quizCategories);
    _validateResponse(response);
    final list = response.data as List<dynamic>;
    final categories = list
        .map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return categories;
  }

  @override
  List<CategoryModel> getPlaceholders() => _placeholders;

  static final List<CategoryModel> _placeholders = List<CategoryModel>.generate(
    6,
    (i) => CategoryModel(
      id: i,
      name: 'Category title',
      description:
          'A short two-line description that hints at what this theme is about.',
      iconUrl: '',
      levelCount: 6,
      completedLevels: 2,
      orderIndex: i,
    ),
  );
}
