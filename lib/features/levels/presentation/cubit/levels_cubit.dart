import 'dart:async';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../quiz/core/quiz_event_service.dart';
import '../../data/repositories/levels_repository.dart';
import 'levels_state.dart';

class LevelsCubit extends BaseCubit<LevelsState> {
  LevelsCubit({
    required LevelsRepository levelsRepository,
    required QuizEventService quizEventService,
  })  : _levelsRepository = levelsRepository,
        super(const LevelsState()) {
    _quizSub = quizEventService.onSubmitted.listen((_) => refreshCurrent());
  }

  final LevelsRepository _levelsRepository;
  int? _lastCategoryId;
  StreamSubscription<int>? _quizSub;

  Future<void> getLevels(int categoryId, {bool refresh = false}) async {
    _lastCategoryId = categoryId;
    if (!refresh) {
      emit(
        state.copyWith(
          status: LevelsStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final response = await _levelsRepository.getLevels(categoryId, page: 0);
      emit(
        state.copyWith(
          status: LevelsStatus.loaded,
          levels: response.levels,
          pagination: () => response.pagination,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: LevelsStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('LevelsCubit.getLevels failed: $e');
      emit(
        state.copyWith(
          status: LevelsStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }

  /// Re-fetch the currently-loaded category in the background. Used after
  /// the user finishes a quiz so the levels list reflects new completion
  /// state and points without flashing the skeleton.
  Future<void> refreshCurrent() async {
    final id = _lastCategoryId;
    if (id == null) return;
    await getLevels(id, refresh: true);
  }

  Future<void> loadMore(int categoryId) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = (state.pagination?.page ?? 0) + 1;
      final response = await _levelsRepository.getLevels(categoryId, page: next);
      emit(
        state.copyWith(
          levels: [...state.levels, ...response.levels],
          pagination: () => response.pagination,
          isLoadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('LevelsCubit.loadMore failed: $e');
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _quizSub?.cancel();
    return super.close();
  }
}
