import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/utils/logger.dart';
import 'language_state.dart';

typedef UpdateLanguageCallback = Future<void> Function(String language);

class LanguageCubit extends BaseCubit<LanguageState> {
  LanguageCubit({UpdateLanguageCallback? updateLanguage})
    : _updateLanguage = updateLanguage,
      super(LanguageState(status: LanguageStatus.initial));

  final UpdateLanguageCallback? _updateLanguage;

  void updateCurrentLanguage(String currentLanguage) {
    emit(state.copyWith(selectedLanguage: () => currentLanguage));
  }

  Future<void> updateLanguage(
    String language, {
    bool shouldSkipBackend = true,
  }) async {
    try {
      emit(state.copyWith(status: LanguageStatus.loading));
      if (!shouldSkipBackend && _updateLanguage != null) {
        await _updateLanguage(language);
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
