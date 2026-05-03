import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/language_repository.dart';
import 'language_state.dart';

class LanguageCubit extends BaseCubit<LanguageState> {
  LanguageCubit({required LanguageRepository repository})
    : _repository = repository,
      super(LanguageState(status: LanguageStatus.initial));

  final LanguageRepository _repository;

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
      emit(
        state.copyWith(
          status: LanguageStatus.success,
          selectedLanguage: () => language,
        ),
      );
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
