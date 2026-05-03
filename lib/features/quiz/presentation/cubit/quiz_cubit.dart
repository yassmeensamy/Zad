import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/quiz_repository.dart';
import '../utils/motivational_messages.dart';
import 'quiz_state.dart';

class QuizCubit extends BaseCubit<QuizState> {
  QuizCubit({required QuizRepository quizRepository})
      : _quizRepository = quizRepository,
        super(const QuizState());

  final QuizRepository _quizRepository;

  Future<void> loadQuiz(int levelId) async {
    emit(
      state.copyWith(
        status: QuizStatus.loading,
        errorMessage: () => null,
      ),
    );
    try {
      final response = await _quizRepository.getQuestions(levelId);
      final questions = response.questions;
      final now = DateTime.now();
      emit(
        QuizState(
          status: QuizStatus.loaded,
          phase: questions.isEmpty ? QuizPhase.finished : QuizPhase.question,
          allQuestions: questions,
          currentQueue: questions,
          retryQueue: const [],
          currentIndex: 0,
          round: 1,
          startedAt: now,
          elapsed: questions.isEmpty ? Duration.zero : null,
          motivationalMessageKey:
              questions.isEmpty ? MotivationalMessages.randomFinish() : null,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: QuizStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('QuizCubit.loadQuiz failed: $e');
      emit(
        state.copyWith(
          status: QuizStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }

  void selectAnswer(int choiceId) {
    if (state.isAnswered) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final correct = question.isCorrect(choiceId);

    if (correct) {
      emit(
        state.copyWith(
          phase: QuizPhase.answeredCorrect,
          selectedChoiceId: () => choiceId,
          firstTryCorrect:
              state.round == 1 ? state.firstTryCorrect + 1 : state.firstTryCorrect,
          motivationalMessageKey: () => MotivationalMessages.randomCorrect(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          phase: QuizPhase.answeredIncorrect,
          selectedChoiceId: () => choiceId,
          retryQueue: [...state.retryQueue, question],
          totalRetries: state.totalRetries + 1,
          motivationalMessageKey: () => MotivationalMessages.randomWrong(),
        ),
      );
    }
  }

  void next() {
    if (!state.isAnswered) return;

    final hasMoreInRound = state.currentIndex + 1 < state.currentQueue.length;
    if (hasMoreInRound) {
      emit(
        state.copyWith(
          phase: QuizPhase.question,
          currentIndex: state.currentIndex + 1,
          selectedChoiceId: () => null,
          motivationalMessageKey: () => null,
        ),
      );
      return;
    }

    if (state.retryQueue.isNotEmpty) {
      emit(
        state.copyWith(
          phase: QuizPhase.question,
          currentQueue: state.retryQueue,
          retryQueue: const [],
          currentIndex: 0,
          round: state.round + 1,
          selectedChoiceId: () => null,
          motivationalMessageKey: () => null,
        ),
      );
      return;
    }

    final elapsed = state.startedAt != null
        ? DateTime.now().difference(state.startedAt!)
        : Duration.zero;

    emit(
      state.copyWith(
        phase: QuizPhase.finished,
        selectedChoiceId: () => null,
        motivationalMessageKey: () => MotivationalMessages.randomFinish(),
        elapsed: () => elapsed,
      ),
    );
  }

  void toggleSave() {
    final question = state.currentQuestion;
    if (question == null) return;
    final next = {...state.savedQuestionIds};
    if (next.contains(question.id)) {
      next.remove(question.id);
    } else {
      next.add(question.id);
    }
    emit(state.copyWith(savedQuestionIds: next));
  }

  void restart() {
    final questions = state.allQuestions;
    if (questions.isEmpty) return;
    emit(
      QuizState(
        status: QuizStatus.loaded,
        phase: QuizPhase.question,
        allQuestions: questions,
        currentQueue: questions,
        retryQueue: const [],
        currentIndex: 0,
        round: 1,
        savedQuestionIds: state.savedQuestionIds,
        startedAt: DateTime.now(),
      ),
    );
  }
}
