import '../models/draft_model.dart';
import '../models/draft_request.dart';
import '../remote/drafts_remote_data_source.dart';

abstract class DraftsRepository {
  Future<List<DraftModel>> getDrafts();
  Future<DraftModel> createDraft(CreateDraftRequest request);
  Future<List<DraftModel>> createDraftsBulk(List<CreateDraftRequest> requests);
  Future<DraftModel> updateDraft(int id, UpdateDraftRequest request);
  Future<void> deleteDraft(int id);
}

class DraftsRepositoryImpl implements DraftsRepository {
  DraftsRepositoryImpl({required DraftsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final DraftsRemoteDataSource _remoteDataSource;

  @override
  Future<List<DraftModel>> getDrafts() => _remoteDataSource.getDrafts();

  @override
  Future<DraftModel> createDraft(CreateDraftRequest request) =>
      _remoteDataSource.createDraft(request);

  @override
  Future<List<DraftModel>> createDraftsBulk(
    List<CreateDraftRequest> requests,
  ) =>
      _remoteDataSource.createDraftsBulk(requests);

  @override
  Future<DraftModel> updateDraft(int id, UpdateDraftRequest request) =>
      _remoteDataSource.updateDraft(id, request);

  @override
  Future<void> deleteDraft(int id) => _remoteDataSource.deleteDraft(id);
}
