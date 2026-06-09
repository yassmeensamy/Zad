import 'package:event_bus/event_bus.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/events/app_events.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/language_repository.dart';
import 'language_state.dart';

class LanguageCubit extends BaseCubit<LanguageState> {
  LanguageCubit({
    required LanguageRepository repository,
    required CacheService cacheService,
    required EventBus eventBus,
  }) : _repository = repository,
       _cacheService = cacheService,
       _eventBus = eventBus,
       super(LanguageState(status: LanguageStatus.initial));

  final LanguageRepository _repository;
  final CacheService _cacheService;
  final EventBus _eventBus;

  void updateCurrentLanguage(String currentLanguage) {
    emit(state.copyWith(selectedLanguage: () => currentLanguage));
  }

  Future<void> updateLanguage(
    String language, {
    bool shouldSkipBackend = false,
  }) async {
    try {
      emit(state.copyWith(status: LanguageStatus.loading));
      if (!shouldSkipBackend) {
        await _repository.updateLanguage(language);
      }
      await _cacheService.set<String>(StorageKeys.kLocaleKey, language);
      emit(
        state.copyWith(
          status: LanguageStatus.success,
          selectedLanguage: () => language,
        ),
      );
      logger.debug('🌐 [lang] firing LanguageChangedEvent($language)');
      _eventBus.fire(LanguageChangedEvent(language));
    } catch (e) {
      logger.debug('Error updating language: $e');
      emit(
        state.copyWith(
          status: LanguageStatus.error,
          errorMessage: () => e.toString(),
        ),
      );
    }
  }

  void clearError() {
    if (state.status.isError) {
      emit(state.copyWith(status: LanguageStatus.initial, errorMessage: null));
    }
  }
}
