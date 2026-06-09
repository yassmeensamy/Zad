import 'dart:async';

import 'package:flutter/painting.dart';

import '../constants/storage_keys.dart';
import '../cubits/base_cubit.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import 'app_startup_state.dart';

class AppStartupCubit extends BaseCubit<AppStartupState> {
  AppStartupCubit({
    required OnboardingRepository onboardingRepository,
    required NotificationService notificationService,
    required CacheService cacheService,
  }) : _onboardingRepository = onboardingRepository,
       _cacheService = cacheService,
       _notificationService = notificationService,
       super(const AppStartupState(status: AppStartupStatus.initial));

  final OnboardingRepository _onboardingRepository;
  final CacheService _cacheService;
  final NotificationService _notificationService;

  Future<void> init(String language) async {
    emit(state.copyWith(status: AppStartupStatus.loading));

    try {
      final onboarding = _resolveNeedsOnboarding();
      await Future.wait([
        _cacheService.set<String>(StorageKeys.kLocaleKey, language),
        _notificationService.init(),
        onboarding,
      ]);
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        status: AppStartupStatus.success,
        needsOnboarding: await onboarding,
      ));
    } catch (e) {
      logger.error('AppStartupCubit.init failed: $e');
      emit(state.copyWith(status: AppStartupStatus.error));
    }
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(needsOnboarding: false));
    await _onboardingRepository.setFirstOpen();
  }

  Future<bool> _resolveNeedsOnboarding() async {
    final firstOpen = await _onboardingRepository.getFirstOpen();
    if (!firstOpen) return false;
    final pages = await _onboardingRepository.getOnboardingData();
    if (pages.isEmpty) return false;
    await _precacheImages(pages.map((p) => p.image));
    return true;
  }

  Future<void> _precacheImages(Iterable<String> urls) async {
    await Future.wait(
      urls.where((u) => u.isNotEmpty).map(_warmImage),
    ).timeout(_precacheTimeout, onTimeout: () => const []);
  }

  Future<void> _warmImage(String url) {
    final completer = Completer<void>();
    final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    void done() {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete();
    }

    listener = ImageStreamListener(
      (_, _) => done(),
      onError: (_, _) => done(),
    );
    stream.addListener(listener);
    return completer.future;
  }

  static const _precacheTimeout = Duration(seconds: 5);
}
