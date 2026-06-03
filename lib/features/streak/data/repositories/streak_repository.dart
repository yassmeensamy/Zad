import '../models/daily_activity_model.dart';
import '../models/streak_model.dart';
import '../remote/streak_remote_data_source.dart';

abstract class StreakRepository {
  Future<StreakModel> getStreak();

  Future<List<DailyActivityModel>> getWeeklyActivity();
}

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl({required StreakRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final StreakRemoteDataSource _remoteDataSource;

  @override
  Future<StreakModel> getStreak() => _remoteDataSource.getStreak();

  @override
  Future<List<DailyActivityModel>> getWeeklyActivity() =>
      _remoteDataSource.getWeeklyActivity();
}
