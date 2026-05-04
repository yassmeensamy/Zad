import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/draft_model.dart';
import '../../data/models/draft_request.dart';
import '../../data/repositories/drafts_repository.dart';
import 'drafts_state.dart';

class DraftsCubit extends BaseCubit<DraftsState> {
  DraftsCubit({required DraftsRepository repository})
    : _repository = repository,
      super(const DraftsState());

  final DraftsRepository _repository;

  Future<void> load({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        emit(
          state.copyWith(
            status: DraftsStatus.loading,
            errorMessage: () => null,
          ),
        );
      }

      final drafts = await _repository.getDrafts();

      emit(state.copyWith(status: DraftsStatus.loaded, drafts: drafts));
    } on ServerException catch (e) {
      logger.error('ServerException loading drafts: ${e.message}');
      emit(
        state.copyWith(
          status: DraftsStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('Failed to load drafts: $e');
    }
  }

  Future<void> create({required int questionId, String? note}) async {
    emit(state.copyWith(
      crudStatus: CrudStatus.loading,
      crudErrorMessage: () => null,
    ));

    try {
      final draft = await _repository.createDraft(
        CreateDraftRequest(questionId: questionId, note: note),
      );
      emit(state.copyWith(
        drafts: [draft, ...state.drafts],
        crudStatus: CrudStatus.created,
      ));
    } on ServerException catch (e) {
      logger.error(
        'Failed to create draft for question $questionId: ${e.message}',
      );
      emit(state.copyWith(
        crudStatus: CrudStatus.error,
        crudErrorMessage: () => e.message,
      ));
    } catch (e) {
      logger.error('Failed to create draft for question $questionId: $e');
      emit(state.copyWith(crudStatus: CrudStatus.error));
    }
  }

  Future<void> updateNote({required int id, String? note}) async {
    final previousDrafts = List<DraftModel>.from(state.drafts);

    // Optimistic: update note immediately + mark row mutating + signal loading
    emit(state.copyWith(
      drafts: [
        for (final d in previousDrafts)
          if (d.id == id) d.copyWith(note: note) else d,
      ],
      mutatingIds: {...state.mutatingIds, id},
      crudStatus: CrudStatus.loading,
      crudErrorMessage: () => null,
    ));

    try {
      final updated = await _repository.updateDraft(
        id,
        UpdateDraftRequest(note: note),
      );

      // Confirm: replace optimistic entry with server-returned model
      emit(state.copyWith(
        drafts: [
          for (final d in state.drafts)
            if (d.id == id) updated else d,
        ],
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.updated,
      ));
    } on ServerException catch (e) {
      logger.error('Failed to update draft $id: ${e.message}');
      emit(state.copyWith(
        drafts: previousDrafts,
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.error,
        crudErrorMessage: () => e.message,
      ));
    } catch (e) {
      logger.error('Failed to update draft $id: $e');
      emit(state.copyWith(
        drafts: previousDrafts,
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.error,
      ));
    }
  }

  Future<void> delete(int id) async {
    final previousDrafts = List<DraftModel>.from(state.drafts);

    // Optimistic: remove from list immediately + mark row mutating
    emit(state.copyWith(
      drafts: previousDrafts.where((d) => d.id != id).toList(),
      mutatingIds: {...state.mutatingIds, id},
      crudStatus: CrudStatus.loading,
      crudErrorMessage: () => null,
    ));

    try {
      await _repository.deleteDraft(id);

      emit(state.copyWith(
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.deleted,
      ));
    } on ServerException catch (e) {
      logger.error('Failed to delete draft $id: ${e.message}');
      emit(state.copyWith(
        drafts: previousDrafts,
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.error,
        crudErrorMessage: () => e.message,
      ));
    } catch (e) {
      logger.error('Failed to delete draft $id: $e');
      emit(state.copyWith(
        drafts: previousDrafts,
        mutatingIds: {...state.mutatingIds}..remove(id),
        crudStatus: CrudStatus.error,
      ));
    }
  }
}
