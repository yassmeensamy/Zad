import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends BaseCubit<OnboardingState> {
  OnboardingCubit({required OnboardingRepository onboardingRepository})
    : _onboardingRepository = onboardingRepository,
      super(const OnboardingState(status: OnboardingStatus.initial));

  final OnboardingRepository _onboardingRepository;

  Future<void> load() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final pages = await _onboardingRepository.getOnboardingData();
      emit(state.copyWith(status: OnboardingStatus.success, pages: pages));
    } catch (e) {
      logger.error('OnboardingCubit.load failed: $e');
      emit(state.copyWith(status: OnboardingStatus.error));
    }
  }

  void changePage(int newPage) {
    emit(state.copyWith(currentPage: newPage));
  }

  Future<void> setFirstOpen() async {
    await _onboardingRepository.setFirstOpen();
  }
}
