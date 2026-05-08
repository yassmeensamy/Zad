import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit({required HomeRepository homeRepository})
    : _homeRepository = homeRepository,
      super(const HomeState());

  final HomeRepository _homeRepository;

  Future<void> getOverview({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final overview = await _homeRepository.getOverview();
      emit(
        state.copyWith(status: HomeStatus.loaded, overview: overview),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('HomeCubit.getOverview failed: $e');
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: () => 'home.load_failed',
        ),
      );
    }
  }
}
