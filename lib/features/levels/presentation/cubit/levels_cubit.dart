import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/levels_repository.dart';
import 'levels_state.dart';

class LevelsCubit extends BaseCubit<LevelsState> {
  LevelsCubit({required LevelsRepository levelsRepository})
      : _levelsRepository = levelsRepository,
        super(const LevelsState());

  final LevelsRepository _levelsRepository;

  Future<void> getLevels(int categoryId, {bool refresh = false}) async {
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
}
