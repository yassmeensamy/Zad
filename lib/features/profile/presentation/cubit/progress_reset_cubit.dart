import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../quiz/core/quiz_event_service.dart';
import '../../../quiz/data/repositories/quiz_repository.dart';
import 'progress_reset_state.dart';

/// Drives the "reset all progress" action on the profile screen. Wraps the
/// quiz-domain reset endpoint and broadcasts a reset event so the categories
/// and levels lists refresh once the user navigates back to them.
class ProgressResetCubit extends BaseCubit<ProgressResetState> {
  ProgressResetCubit({
    required QuizRepository quizRepository,
    required QuizEventService quizEventService,
  }) : _quizRepository = quizRepository,
       _quizEvents = quizEventService,
       super(const ProgressResetState());

  final QuizRepository _quizRepository;
  final QuizEventService _quizEvents;

  Future<void> resetAll() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: ProgressResetStatus.loading,
        errorMessage: () => null,
      ),
    );
    try {
      await _quizRepository.resetAll();
      _quizEvents.notifyReset();
      emit(state.copyWith(status: ProgressResetStatus.success));
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: ProgressResetStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('ProgressResetCubit.resetAll failed: $e');
      emit(
        state.copyWith(
          status: ProgressResetStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }
}
