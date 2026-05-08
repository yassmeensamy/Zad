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
  })  : _categoriesRepository = categoriesRepository,
        super(const CategoriesState()) {
    _quizSub = quizEventService.onSubmitted.listen((_) => refreshCurrent());
  }

  final CategoriesRepository _categoriesRepository;
  StreamSubscription<int>? _quizSub;

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
        state.copyWith(
          status: CategoriesStatus.loaded,
          categories: categories,
        ),
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

  @override
  Future<void> close() async {
    await _quizSub?.cancel();
    return super.close();
  }
}
