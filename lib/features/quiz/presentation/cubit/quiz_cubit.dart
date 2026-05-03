import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/quiz_repository.dart';
import '../utils/motivational_messages.dart';
import 'quiz_state.dart';

class QuizCubit extends BaseCubit<QuizState> {
  QuizCubit({
    required QuizRepository quizRepository,
    DateTime Function() now = DateTime.now,
    MotivationalMessages? messages,
  })  : _quizRepository = quizRepository,
        _now = now,
        _messages = messages ?? MotivationalMessages(),
        super(const QuizState());

  final QuizRepository _quizRepository;
  final DateTime Function() _now;
  final MotivationalMessages _messages;

  /// Answer faster than this on the first try and the question scores 2 pts;
  /// slower (still on the first try) scores 1 pt.
  static const _fastAnswerThreshold = Duration(seconds: 10);

  Future<void> loadQuiz(int levelId) async {
    emit(
      state.copyWith(
        status: QuizStatus.loading,
        errorMessage: () => null,
      ),
    );
    try {
      final response = await _quizRepository.getQuestions(levelId);
      emit(_freshState(
        questions: response.questions,
        savedQuestionIds: state.savedQuestionIds,
      ));
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
    if (!state.isLoaded || state.isAnswered || state.isFinished) return;
    final question = state.currentQuestion;
    if (question == null) return;

    if (question.isCorrect(choiceId)) {
      _emitCorrect(choiceId);
    } else {
      _emitIncorrect(choiceId, question);
    }
  }

  void next() {
    if (!state.isAnswered) return;

    if (state.currentIndex + 1 < state.currentQueue.length) {
      emit(
        state.copyWith(
          phase: QuizPhase.question,
          currentIndex: state.currentIndex + 1,
          selectedChoiceId: () => null,
          motivationalMessageKey: () => null,
          questionShownAt: () => _now(),
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
          questionShownAt: () => _now(),
        ),
      );
      return;
    }

    final startedAt = state.startedAt;
    final elapsed =
        startedAt != null ? _now().difference(startedAt) : Duration.zero;
    emit(
      state.copyWith(
        phase: QuizPhase.finished,
        selectedChoiceId: () => null,
        motivationalMessageKey: () => _messages.randomFinish(),
        elapsed: () => elapsed,
      ),
    );
  }

  void toggleSave() {
    final question = state.currentQuestion;
    if (question == null) return;
    final next = {...state.savedQuestionIds};
    if (!next.remove(question.id)) next.add(question.id);
    emit(state.copyWith(savedQuestionIds: next));
  }

  void restart() {
    if (state.allQuestions.isEmpty) return;
    emit(_freshState(
      questions: state.allQuestions,
      savedQuestionIds: state.savedQuestionIds,
    ));
  }

  void _emitCorrect(int choiceId) {
    var pointsEarned = 0;
    var firstTryCorrect = state.firstTryCorrect;
    if (state.round == 1) {
      firstTryCorrect++;
      pointsEarned = _scoreFor(_elapsedSinceShown());
    }
    emit(
      state.copyWith(
        phase: QuizPhase.answeredCorrect,
        selectedChoiceId: () => choiceId,
        firstTryCorrect: firstTryCorrect,
        points: state.points + pointsEarned,
        motivationalMessageKey: () => _messages.randomCorrect(),
      ),
    );
  }

  void _emitIncorrect(int choiceId, QuestionModel question) {
    emit(
      state.copyWith(
        phase: QuizPhase.answeredIncorrect,
        selectedChoiceId: () => choiceId,
        retryQueue: [...state.retryQueue, question],
        totalRetries: state.totalRetries + 1,
        motivationalMessageKey: () => _messages.randomWrong(),
      ),
    );
  }

  Duration _elapsedSinceShown() {
    final shownAt = state.questionShownAt;
    if (shownAt == null) return Duration.zero;
    return _now().difference(shownAt);
  }

  int _scoreFor(Duration elapsed) =>
      elapsed < _fastAnswerThreshold ? 2 : 1;

  QuizState _freshState({
    required List<QuestionModel> questions,
    required Set<int> savedQuestionIds,
  }) {
    final now = _now();
    final empty = questions.isEmpty;
    return QuizState(
      status: QuizStatus.loaded,
      phase: empty ? QuizPhase.finished : QuizPhase.question,
      allQuestions: questions,
      currentQueue: questions,
      savedQuestionIds: savedQuestionIds,
      startedAt: now,
      questionShownAt: empty ? null : now,
      elapsed: empty ? Duration.zero : null,
      motivationalMessageKey: empty ? _messages.randomFinish() : null,
    );
  }
}
