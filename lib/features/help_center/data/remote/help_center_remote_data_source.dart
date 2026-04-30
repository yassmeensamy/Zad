import '../models/support_request_model.dart';

abstract class HelpCenterRemoteDataSource {
  Future<SupportRequestModel> sendSupportRequest(SupportRequestModel request);
}

/// Mock implementation that fakes a network round-trip with [Future.delayed]
/// and assigns an incrementing id. Swap this out for an API-backed source
/// when the backend is available — the cubit/repository contract stays the
/// same.
class HelpCenterRemoteDataSourceImpl implements HelpCenterRemoteDataSource {
  HelpCenterRemoteDataSourceImpl();

  int _nextId = 1;

  @override
  Future<SupportRequestModel> sendSupportRequest(
    SupportRequestModel request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return request.copyWith(id: _nextId++, createdAt: DateTime.now());
  }
}
