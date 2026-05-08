import 'dart:async';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import 'splash_state.dart';

class SplashCubit extends BaseCubit<SplashStates> {
  SplashCubit({
    required OnboardingRepository onboardingRepository,
    required NotificationService notificationService,
    required CacheService cacheService,
  }) : _onboardingRepository = onboardingRepository,
       _cacheService = cacheService,
       _notificationService = notificationService,
       super(const SplashStates(status: SplashStatus.initial));

  final OnboardingRepository _onboardingRepository;
  final CacheService _cacheService;
  final NotificationService _notificationService;

  Future<void> init(String language) async {
    emit(state.copyWith(status: SplashStatus.loading));

    try {
      await Future.wait([
        _cacheService.set<String>(StorageKeys.kLocaleKey, language),
        _notificationService.init(),
      ]);

      final isFirstAppLaunch = await _onboardingRepository.getFirstOpen();
      if (isFirstAppLaunch) {
        await _handleFirstLaunch();
      } else {
        logger.debug('Not first launch, skipping onboarding');
        Future.delayed(const Duration(seconds: 2), () {
                  _emitSuccess(SplashDestination.authCheck);

        });
      }
    } catch (e) {
      logger.error('SplashCubit.init failed: $e');
      emit(state.copyWith(status: SplashStatus.error));
    }
  }

  Future<void> _handleFirstLaunch() async {
    final pages = await _onboardingRepository.getOnboardingData();
    if (pages.isEmpty) {
      _emitSuccess(SplashDestination.authCheck);
    } else {
      _emitSuccess(SplashDestination.onboarding);
    }
  }

  void _emitSuccess(SplashDestination destination) {
    emit(
      state.copyWith(status: SplashStatus.success, destination: destination),
    );
  }
}
