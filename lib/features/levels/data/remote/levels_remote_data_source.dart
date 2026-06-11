import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/levels_response.dart';

abstract class LevelsRemoteDataSource {
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0});

  /// Resets the current user's progress for a single level.
  Future<void> resetLevel(int levelId);
}

class LevelsRemoteDataSourceImpl implements LevelsRemoteDataSource {
  LevelsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0}) async {
    final response = await _networkService.get(
      _endpoints.levelsByCategoryId(categoryId),
      queryParameters: {'page': page},
    );
    response.validated();
    return LevelsResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> resetLevel(int levelId) async {
    final response = await _networkService.post(_endpoints.resetLevel(levelId));
    response.validated(const [200, 201, 204]);
  }
}
