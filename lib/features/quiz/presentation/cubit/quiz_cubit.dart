import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_submission_request.dart';
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

  int? _levelId;

  /// Answer faster than this on the first try and the question scores 2 pts;
  /// slower (still on the first try) scores 1 pt.
  static const _fastAnswerThreshold = Duration(seconds: 10);

  Future<void> loadQuiz(int levelId, {bool review = false}) async {
    _levelId = levelId;
    emit(state.copyWith(
      status: QuizStatus.loading,
      errorMessage: () => null,
      isReview: review,
    ));
    try {
      final response = await _quizRepository.getQuestions(levelId);
      emit(_buildLoadedState(response.questions, review: review));
    } on ServerException catch (e) {
      _emitLoadError(e.message);
    } catch (e) {
      logger.error('QuizCubit.loadQuiz failed: $e');
      _emitLoadError('errors.generic');
    }
  }

  void selectAnswer(int choiceId) {
    if (!state.isLoaded || state.isAnswered || state.isFinished) return;
    final question = state.currentQuestion;
    if (question == null) return;

    if (question.isCorrect(choiceId)) {
      _emitCorrect(choiceId, question);
    } else {
      _emitIncorrect(choiceId, question);
    }
  }

  void next() {
    if (state.isReview) {
      _reviewAdvance();
      return;
    }
    if (!state.isAnswered) return;

    if (!state.isLastInCurrentRound) {
      _advanceWithinRound();
    } else if (state.retryQueue.isNotEmpty) {
      _startRetryRound();
    } else {
      _finish();
    }
  }

  void restart() {
    if (state.allQuestions.isEmpty) return;
    emit(_buildLoadedState(state.allQuestions, review: false));
  }

  /// Submits the quiz attempt to the server. Triggered automatically when
  /// the user reaches [QuizPhase.finished], and can be re-invoked from the
  /// UI to retry on failure.
  Future<void> submit() async {
    final levelId = _levelId;
    if (levelId == null || state.isSubmitting) return;

    final request = QuizSubmissionRequest(
      pointsEarned: state.points,
      answers: [
        for (final q in state.allQuestions)
          QuizAnswerSubmission(
            questionId: q.id,
            isCorrect: state.firstTryCorrectIds.contains(q.id),
          ),
      ],
    );

    emit(state.copyWith(
      submissionStatus: SubmissionStatus.submitting,
      submissionError: () => null,
    ));

    try {
      final result = await _quizRepository.submitQuiz(levelId, request);
      emit(state.copyWith(
        submissionStatus: SubmissionStatus.success,
        submissionResult: () => result,
      ));
    } on ServerException catch (e) {
      logger.error('QuizCubit.submit failed: ${e.message}');
      _emitSubmitError(e.message);
    } catch (e) {
      logger.error('QuizCubit.submit failed: $e');
      _emitSubmitError('errors.generic');
    }
  }

  void _emitCorrect(int choiceId, QuestionModel question) {
    final isFirstTry = state.round == 1;
    final pointsEarned = isFirstTry ? _scoreFor(_elapsedSinceShown()) : 0;

    emit(state.copyWith(
      phase: QuizPhase.answeredCorrect,
      selectedChoiceId: () => choiceId,
      firstTryCorrect:
          isFirstTry ? state.firstTryCorrect + 1 : state.firstTryCorrect,
      firstTryCorrectIds: isFirstTry
          ? {...state.firstTryCorrectIds, question.id}
          : state.firstTryCorrectIds,
      points: state.points + pointsEarned,
      motivationalMessageKey: () => _messages.randomCorrect(),
    ));

    if (state.isLastInCurrentRound && state.retryQueue.isEmpty) {
      submit();
    }
  }

  void _emitIncorrect(int choiceId, QuestionModel question) {
    emit(state.copyWith(
      phase: QuizPhase.answeredIncorrect,
      selectedChoiceId: () => choiceId,
      retryQueue: [...state.retryQueue, question],
      totalRetries: state.totalRetries + 1,
      motivationalMessageKey: () => _messages.randomWrong(),
    ));
  }

  void _advanceWithinRound() {
    emit(state.copyWith(
      phase: QuizPhase.question,
      currentIndex: state.currentIndex + 1,
      selectedChoiceId: () => null,
      motivationalMessageKey: () => null,
      questionShownAt: () => _now(),
    ));
  }

  void _startRetryRound() {
    emit(state.copyWith(
      phase: QuizPhase.question,
      currentQueue: state.retryQueue,
      retryQueue: const [],
      currentIndex: 0,
      round: state.round + 1,
      selectedChoiceId: () => null,
      motivationalMessageKey: () => null,
      questionShownAt: () => _now(),
    ));
  }

  void _finish() {
    final startedAt = state.startedAt;
    final elapsed =
        startedAt != null ? _now().difference(startedAt) : Duration.zero;
    emit(state.copyWith(
      phase: QuizPhase.finished,
      selectedChoiceId: () => null,
      motivationalMessageKey: () => _messages.randomFinish(),
      elapsed: () => elapsed,
    ));
  }

  void _reviewAdvance() {
    if (state.isLastInCurrentRound) {
      emit(state.copyWith(phase: QuizPhase.finished));
    } else {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  Duration _elapsedSinceShown() {
    final shownAt = state.questionShownAt;
    return shownAt == null ? Duration.zero : _now().difference(shownAt);
  }

  int _scoreFor(Duration elapsed) =>
      elapsed < _fastAnswerThreshold ? 2 : 1;

  /// Builds the loaded state for both fresh and review runs. Review mode
  /// skips the timer/scoring fields since the user is just walking through
  /// previously-completed questions.
  QuizState _buildLoadedState(
    List<QuestionModel> questions, {
    required bool review,
  }) {
    final empty = questions.isEmpty;
    final now = review ? null : _now();
    return QuizState(
      status: QuizStatus.loaded,
      phase: empty ? QuizPhase.finished : QuizPhase.question,
      allQuestions: questions,
      currentQueue: questions,
      isReview: review,
      startedAt: now,
      questionShownAt: empty ? null : now,
      elapsed: !review && empty ? Duration.zero : null,
      motivationalMessageKey:
          !review && empty ? _messages.randomFinish() : null,
    );
  }

  void _emitLoadError(String? message) {
    emit(state.copyWith(
      status: QuizStatus.error,
      errorMessage: () => message,
    ));
  }

  void _emitSubmitError(String? message) {
    emit(state.copyWith(
      submissionStatus: SubmissionStatus.error,
      submissionError: () => message,
    ));
  }
}
