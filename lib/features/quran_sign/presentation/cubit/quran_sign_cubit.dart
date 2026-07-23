import 'dart:async';

import 'package:event_bus/event_bus.dart';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/events/app_events.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/quran_sign_repository.dart';
import 'quran_sign_state.dart';

class QuranSignCubit extends BaseCubit<QuranSignState> {
  QuranSignCubit({
    required QuranSignRepository quranSignRepository,
    required EventBus eventBus,
  }) : _quranSignRepository = quranSignRepository,
       super(const QuranSignState()) {
    _langSub = eventBus.on<LanguageChangedEvent>().listen((e) {
      logger.debug(
        '🏠 [quran-sign] got LanguageChangedEvent(${e.languageCode}) '
        'status=${state.status} → ${state.isInitial ? "SKIP (initial)" : "refetch"}',
      );
      load(refresh: true);
    });
  }

  final QuranSignRepository _quranSignRepository;
  StreamSubscription<LanguageChangedEvent>? _langSub;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: QuranSignStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final sign = await _quranSignRepository.getRandomSign();
      emit(
        state.copyWith(status: QuranSignStatus.loaded, sign: sign),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: QuranSignStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('QuranSignCubit.load failed: $e');
      emit(
        state.copyWith(
          status: QuranSignStatus.error,
          errorMessage: () => 'home.load_failed',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _langSub?.cancel();
    return super.close();
  }
}
