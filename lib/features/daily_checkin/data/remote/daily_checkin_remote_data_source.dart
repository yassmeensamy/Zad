import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/daily_checkin_model.dart';

abstract class DailyCheckInRemoteDataSource {
  Future<DailyCheckInModel> checkIn();
}

class DailyCheckInRemoteDataSourceImpl implements DailyCheckInRemoteDataSource {
  DailyCheckInRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<DailyCheckInModel> checkIn() async {
    final response = await _networkService.post(_endpoints.dailyCheckIn);
    response.validated();
    return DailyCheckInModel.fromMap(response.data as Map<String, dynamic>);
  }
}
