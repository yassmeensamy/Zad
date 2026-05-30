import 'dart:async';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../quiz/core/quiz_event_service.dart';
import '../../data/repositories/categories_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends BaseCubit<CategoriesState> {
  CategoriesCubit({
    required CategoriesRepository categoriesRepository,
    required QuizEventService quizEventService,
  }) : _categoriesRepository = categoriesRepository,
       _quizEvents = quizEventService,
       super(const CategoriesState()) {
    _submitSub = quizEventService.onSubmitted.listen((_) => refreshCurrent());
    _resetSub = quizEventService.onReset.listen((_) => refreshCurrent());
  }

  final CategoriesRepository _categoriesRepository;
  final QuizEventService _quizEvents;
  StreamSubscription<int>? _submitSub;
  StreamSubscription<void>? _resetSub;

  Future<void> getCategories({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: CategoriesStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final categories = await _categoriesRepository.getCategories();
      emit(
        state.copyWith(status: CategoriesStatus.loaded, categories: categories),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: CategoriesStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('CategoriesCubit.getCategories failed: $e');
      emit(
        state.copyWith(
          status: CategoriesStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }

  /// Re-fetch categories in the background after a quiz submission so the
  /// list reflects updated completion state and points without flashing
  /// the skeleton.
  Future<void> refreshCurrent() => getCategories(refresh: true);

  /// Resets the user's progress for [categoryId]. Broadcasts a reset event so
  /// every listening list — this one included — refreshes exactly once via
  /// its [QuizEventService.onReset] subscription. (Refreshing here as well
  /// would fire a second identical GET and trip the network layer's
  /// duplicate-request guard.)
  Future<void> resetCategory(int categoryId) async {
    if (state.isResetting(categoryId)) return;
    emit(
      state.copyWith(
        resettingCategoryIds: {...state.resettingCategoryIds, categoryId},
        errorMessage: () => null,
      ),
    );
    try {
      await _categoriesRepository.resetCategory(categoryId);
      _quizEvents.notifyReset();
    } on ServerException catch (e) {
      emit(state.copyWith(errorMessage: () => e.message));
    } catch (e) {
      logger.error('CategoriesCubit.resetCategory failed: $e');
      emit(state.copyWith(errorMessage: () => 'errors.generic'));
    } finally {
      emit(
        state.copyWith(
          resettingCategoryIds: {...state.resettingCategoryIds}
            ..remove(categoryId),
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
