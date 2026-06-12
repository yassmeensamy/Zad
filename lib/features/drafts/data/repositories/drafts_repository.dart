import '../../../../core/api/network_failure.dart';
import '../../../quiz/data/models/choice_model.dart';
import '../../../quiz/data/models/question_model.dart';
import '../local/pending_drafts_dao.dart';
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
  DraftsRepositoryImpl({
    required DraftsRemoteDataSource remoteDataSource,
    required PendingDraftsDao pendingDao,
  })  : _remoteDataSource = remoteDataSource,
        _pendingDao = pendingDao;

  final DraftsRemoteDataSource _remoteDataSource;
  final PendingDraftsDao _pendingDao;

  @override
  Future<List<DraftModel>> getDrafts() => _remoteDataSource.getDrafts();

  @override
  Future<DraftModel> createDraft(CreateDraftRequest request) async {
    try {
      return await _remoteDataSource.createDraft(request);
    } catch (e) {
      if (isConnectivityError(e)) {
        // Offline: queue the bookmark locally and hand the UI an optimistic
        // draft so the quiz bookmark toggles on immediately. The real
        // server-backed draft replaces it on the next load after sync.
        await _pendingDao.insertDraft(
          questionId: request.questionId,
          note: request.note,
        );
        return _offlineDraft(request);
      }
      rethrow;
    }
  }

  @override
  Future<List<DraftModel>> createDraftsBulk(
    List<CreateDraftRequest> requests,
  ) =>
      _remoteDataSource.createDraftsBulk(requests);

  @override
  Future<DraftModel> updateDraft(int id, UpdateDraftRequest request) =>
      _remoteDataSource.updateDraft(id, request);

  @override
  Future<void> deleteDraft(int id) async {
    // Optimistic offline drafts carry a negative sentinel id (never assigned by
    // the server). Toggling one off simply drops it from the pending queue —
    // there is nothing on the server to delete yet.
    if (id < 0) {
      await _pendingDao.removeUnsyncedByQuestion(offlineQuestionId(id));
      return;
    }
    await _remoteDataSource.deleteDraft(id);
  }

  /// Builds the optimistic draft returned for an offline create. The id is a
  /// negative sentinel derived from the question id so it never collides with a
  /// real server id and the offline toggle-off can recover the question id.
  DraftModel _offlineDraft(CreateDraftRequest request) => DraftModel(
        id: offlineDraftId(request.questionId),
        note: request.note,
        createdAt: DateTime.now(),
        question: QuestionModel(
          id: request.questionId,
          text: '',
          choices: const <ChoiceModel>[],
          correctIndex: -1,
          isDrafted: true,
        ),
      );

  /// Negative sentinel id for an offline draft of [questionId].
  static int offlineDraftId(int questionId) => -questionId;

  /// Recovers the question id from an offline draft's sentinel [draftId].
  static int offlineQuestionId(int draftId) => -draftId;
}
