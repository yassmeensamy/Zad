import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
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

  @override
  Future<StreakModel> getStreak() async {
    final response = await _networkService.get(_endpoints.streak);
    response.validated();
    return StreakModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DailyActivityModel>> getWeeklyActivity() async {
    final response = await _networkService.get(_endpoints.weeklyStreak);
    response.validated();
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DailyActivityModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
