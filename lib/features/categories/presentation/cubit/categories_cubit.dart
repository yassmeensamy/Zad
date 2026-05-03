import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/categories_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends BaseCubit<CategoriesState> {
  CategoriesCubit({required CategoriesRepository categoriesRepository})
      : _categoriesRepository = categoriesRepository,
        super(const CategoriesState());

  final CategoriesRepository _categoriesRepository;

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
}
