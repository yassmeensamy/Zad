import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/learn_repository.dart';
import 'learn_state.dart';

class LearnCubit extends BaseCubit<LearnState> {
  LearnCubit({required LearnRepository learnRepository})
      : _learnRepository = learnRepository,
        super(const LearnState());

  final LearnRepository _learnRepository;

  Future<void> getCategories({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: LearnStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final categories = await _learnRepository.getCategories();
      emit(
        state.copyWith(
          status: LearnStatus.loaded,
          categories: categories,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: LearnStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('LearnCubit.getCategories failed: $e');
      emit(
        state.copyWith(
          status: LearnStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }
}
