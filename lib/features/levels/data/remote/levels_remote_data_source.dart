import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/level_model.dart';
import '../models/levels_response.dart';

abstract class LevelsRemoteDataSource {
  Future<LevelsResponse> getLevels(int categoryId, {int page = 0});
  List<LevelModel> getPlaceholders();
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
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<LevelsResponse> getLevels(
    int categoryId, {
    int page = 0,
  }) async {
    final response = await _networkService.get(
      _endpoints.levelsByCategoryId(categoryId),
      queryParameters: {'page': page},
    );
    _validateResponse(response);
    return LevelsResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  List<LevelModel> getPlaceholders() => _placeholders;

  static final List<LevelModel> _placeholders = List<LevelModel>.generate(
    6,
    (i) => LevelModel(
      id: i,
      title: 'Level title',
      order: i + 1,
      questionCount: 10,
      completedQuestions: i < 2 ? 10 : (i == 2 ? 4 : 0),
      passingGrade: 70,
      status: i < 2
          ? LevelStatus.completed
          : i == 2
              ? LevelStatus.inProgress
              : LevelStatus.locked,
    ),
  );
}
