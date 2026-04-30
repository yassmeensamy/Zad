import '../models/support_request_model.dart';
import '../remote/help_center_remote_data_source.dart';

abstract class HelpCenterRepository {
  Future<SupportRequestModel> sendSupportRequest(SupportRequestModel request);
}

class HelpCenterRepositoryImpl implements HelpCenterRepository {
  HelpCenterRepositoryImpl({required HelpCenterRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final HelpCenterRemoteDataSource _remoteDataSource;

  @override
  Future<SupportRequestModel> sendSupportRequest(
    SupportRequestModel request,
  ) => _remoteDataSource.sendSupportRequest(request);
}
