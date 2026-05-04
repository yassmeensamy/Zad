import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/draft_model.dart';
import '../models/draft_request.dart';

abstract class DraftsRemoteDataSource {
  Future<List<DraftModel>> getDrafts();
  Future<DraftModel> createDraft(CreateDraftRequest request);
  Future<List<DraftModel>> createDraftsBulk(List<CreateDraftRequest> requests);
  Future<DraftModel> updateDraft(int id, UpdateDraftRequest request);
  Future<void> deleteDraft(int id);
}

class DraftsRemoteDataSourceImpl implements DraftsRemoteDataSource {
  DraftsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  })  : _networkService = networkService,
        _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201, 204],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<List<DraftModel>> getDrafts() async {
    final response = await _networkService.get(_endpoints.drafts);
    _validateResponse(response);
    return (response.data as List<dynamic>)
        .map((e) => DraftModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DraftModel> createDraft(CreateDraftRequest request) async {
    final response = await _networkService.post(
      _endpoints.drafts,
      data: request.toMap(),
    );
    _validateResponse(response);
    return DraftModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DraftModel>> createDraftsBulk(
    List<CreateDraftRequest> requests,
  ) async {
    final response = await _networkService.post(
      _endpoints.draftsBulk,
      data: requests.map((r) => r.toMap()).toList(),
    );
    _validateResponse(response);
    return (response.data as List<dynamic>)
        .map((e) => DraftModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DraftModel> updateDraft(int id, UpdateDraftRequest request) async {
    final response = await _networkService.patch(
      _endpoints.draftById(id),
      data: request.toMap(),
    );
    _validateResponse(response);
    return DraftModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDraft(int id) async {
    final response = await _networkService.delete(_endpoints.draftById(id));
    _validateResponse(response);
  }
}
