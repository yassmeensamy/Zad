import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/daily_activity_model.dart';
import '../models/streak_model.dart';

abstract class StreakRemoteDataSource {
  Future<StreakModel> getStreak();

  Future<List<DailyActivityModel>> getWeeklyActivity();
}

class StreakRemoteDataSourceImpl implements StreakRemoteDataSource {
  StreakRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<StreakModel> getStreak() async {
    final response = await _networkService.get(_endpoints.streak);
    _validateResponse(response);
    return StreakModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DailyActivityModel>> getWeeklyActivity() async {
    final response = await _networkService.get(_endpoints.weeklyStreak);
    _validateResponse(response);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DailyActivityModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
