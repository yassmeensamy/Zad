import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
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
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<List<DraftModel>> getDrafts() async {
    final response = await _networkService.get(_endpoints.drafts);
    response.validated();
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
    response.validated();
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
    response.validated();
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
    response.validated();
    return DraftModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDraft(int id) async {
    final response = await _networkService.delete(_endpoints.draftById(id));
    response.validated();
  }
}
