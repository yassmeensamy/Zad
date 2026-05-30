import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
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

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0}) async {
    final response = await _networkService.get(
      _endpoints.levelsByCategoryId(categoryId),
      queryParameters: {'page': page},
    );
    _validateResponse(response);
    return LevelsResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> resetLevel(int levelId) async {
    final response = await _networkService.post(_endpoints.resetLevel(levelId));
    _validateResponse(response, const [200, 201, 204]);
  }
}
