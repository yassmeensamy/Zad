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
  }) : _levelsRepository = levelsRepository,
       _quizEvents = quizEventService,
       super(const LevelsState()) {
    _submitSub = quizEventService.onSubmitted.listen((_) => refreshCurrent());
    _resetSub = quizEventService.onReset.listen((_) => refreshCurrent());
  }

  final LevelsRepository _levelsRepository;
  final QuizEventService _quizEvents;
  int? _lastCategoryId;
  StreamSubscription<int>? _submitSub;
  StreamSubscription<void>? _resetSub;

  Future<void> getLevels(int categoryId, {bool refresh = false}) async {
    _lastCategoryId = categoryId;
    if (!refresh) {
      emit(
        state.copyWith(status: LevelsStatus.loading, errorMessage: () => null),
      );
    }
    try {
      final response = await _levelsRepository.getLevels(categoryId, page: 0);
      emit(
        state.copyWith(
          status: LevelsStatus.loaded,
          levels: response.levels,
          pagination: () => response.pagination,
          summaryCompleted: () => response.completedLevels,
          summaryTotal: () => response.totalLevels,
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
      final response = await _levelsRepository.getLevels(
        categoryId,
        page: next,
      );
      emit(
        state.copyWith(
          levels: [...state.levels, ...response.levels],
          pagination: () => response.pagination,
          summaryCompleted: () => response.completedLevels,
          summaryTotal: () => response.totalLevels,
          isLoadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: () => e.message));
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

  /// Resets the user's progress for [levelId]. Broadcasts a reset event so
  /// every listening list — this one included — refreshes exactly once via
  /// its [QuizEventService.onReset] subscription. (Refreshing here as well
  /// would fire a second identical GET and trip the network layer's
  /// duplicate-request guard.)
  Future<void> resetLevel(int levelId) async {
    if (state.isResetting(levelId)) return;
    emit(
      state.copyWith(
        resettingLevelIds: {...state.resettingLevelIds, levelId},
        errorMessage: () => null,
      ),
    );
    try {
      await _levelsRepository.resetLevel(levelId);
      _quizEvents.notifyReset();
    } on ServerException catch (e) {
      emit(state.copyWith(errorMessage: () => e.message));
    } catch (e) {
      logger.error('LevelsCubit.resetLevel failed: $e');
      emit(state.copyWith(errorMessage: () => 'errors.generic'));
    } finally {
      emit(
        state.copyWith(
          resettingLevelIds: {...state.resettingLevelIds}..remove(levelId),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _submitSub?.cancel();
    await _resetSub?.cancel();
    return super.close();
  }
}
