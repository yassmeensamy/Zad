import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/total_solved_response.dart';
import '../models/weekly_stats_response.dart';

abstract class QuizStatsRemoteDataSource {
  /// `GET /api/quiz/stats/weekly` — last-week solved totals and daily breakdown.
  Future<WeeklyStatsResponse> getWeeklyStats();

  /// `GET /api/quiz/stats/total-solved` — lifetime solved question count.
  Future<TotalSolvedResponse> getTotalSolved();
}

class QuizStatsRemoteDataSourceImpl implements QuizStatsRemoteDataSource {
  QuizStatsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<WeeklyStatsResponse> getWeeklyStats() async {
    final response = await _networkService.get(_endpoints.quizStatsWeekly);
    response.validated();
    return WeeklyStatsResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TotalSolvedResponse> getTotalSolved() async {
    final response = await _networkService.get(_endpoints.quizStatsTotalSolved);
    response.validated();
    return TotalSolvedResponse.fromMap(response.data as Map<String, dynamic>);
  }
}
