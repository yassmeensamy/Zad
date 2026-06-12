import '../models/total_solved_response.dart';
import '../models/weekly_stats_response.dart';
import '../remote/quiz_stats_remote_data_source.dart';

abstract class QuizStatsRepository {
  Future<WeeklyStatsResponse> getWeeklyStats();
  Future<TotalSolvedResponse> getTotalSolved();
}

class QuizStatsRepositoryImpl implements QuizStatsRepository {
  QuizStatsRepositoryImpl({required QuizStatsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuizStatsRemoteDataSource _remoteDataSource;

  @override
  Future<WeeklyStatsResponse> getWeeklyStats() =>
      _remoteDataSource.getWeeklyStats();

  @override
  Future<TotalSolvedResponse> getTotalSolved() =>
      _remoteDataSource.getTotalSolved();
}
