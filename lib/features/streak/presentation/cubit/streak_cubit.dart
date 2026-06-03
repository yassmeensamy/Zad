import 'dart:async';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../quiz/core/quiz_event_service.dart';
import '../../data/models/daily_activity_model.dart';
import '../../data/models/streak_model.dart';
import '../../data/repositories/streak_repository.dart';
import 'streak_state.dart';

class StreakCubit extends BaseCubit<StreakState> {
  StreakCubit({
    required StreakRepository streakRepository,
    required QuizEventService quizEventService,
  }) : _streakRepository = streakRepository,
       super(const StreakState()) {
    _submitSub =
        quizEventService.onSubmitted.listen((_) => load(refresh: true));
  }

  final StreakRepository _streakRepository;
  StreamSubscription<int>? _submitSub;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: StreakStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final results = await Future.wait([
        _streakRepository.getStreak(),
        _streakRepository.getWeeklyActivity(),
      ]);
      emit(
        state.copyWith(
          status: StreakStatus.loaded,
          streak: results[0] as StreakModel,
          weekly: results[1] as List<DailyActivityModel>,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: StreakStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('StreakCubit.load failed: $e');
      emit(
        state.copyWith(
          status: StreakStatus.error,
          errorMessage: () => 'home.load_failed',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _submitSub?.cancel();
    return super.close();
  }
}
