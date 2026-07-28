import '../models/daily_checkin_model.dart';
import '../remote/daily_checkin_remote_data_source.dart';

abstract class DailyCheckInRepository {
  Future<DailyCheckInModel> checkIn();
}

class DailyCheckInRepositoryImpl implements DailyCheckInRepository {
  DailyCheckInRepositoryImpl({
    required DailyCheckInRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DailyCheckInRemoteDataSource _remoteDataSource;

  @override
  Future<DailyCheckInModel> checkIn() => _remoteDataSource.checkIn();
}
