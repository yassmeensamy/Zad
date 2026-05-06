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

  Future<void> loadQuiz(int levelId) async {
    _levelId = levelId;
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
        savedQuestionIds: const {},
        draftIdByQuestion: const {},
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
      _emitCorrect(choiceId, question);
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

  /// Replaces the saved-questions seed in one shot. Called by the screen
  /// after fetching the user's existing drafts on quiz load.
  void seedDrafts({
    required Set<int> savedQuestionIds,
    required Map<int, int> draftIdByQuestion,
  }) {
    emit(
      state.copyWith(
        savedQuestionIds: savedQuestionIds,
        draftIdByQuestion: draftIdByQuestion,
      ),
    );
  }

  /// Marks a question as saved with its server-assigned draft id.
  void markSaved({required int questionId, required int draftId}) {
    emit(
      state.copyWith(
        savedQuestionIds: {...state.savedQuestionIds, questionId},
        draftIdByQuestion: {...state.draftIdByQuestion, questionId: draftId},
      ),
    );
  }

  void markUnsaved(int questionId) {
    final nextSaved = {...state.savedQuestionIds}..remove(questionId);
    final nextMap = {...state.draftIdByQuestion}..remove(questionId);
    emit(
      state.copyWith(
        savedQuestionIds: nextSaved,
        draftIdByQuestion: nextMap,
      ),
    );
  }

  void setSaving({required int questionId, required bool active}) {
    final next = {...state.savingQuestionIds};
    if (active) {
      next.add(questionId);
    } else {
      next.remove(questionId);
    }
    emit(state.copyWith(savingQuestionIds: next));
  }

  void restart() {
    if (state.allQuestions.isEmpty) return;
    emit(_freshState(
      questions: state.allQuestions,
      savedQuestionIds: state.savedQuestionIds,
      draftIdByQuestion: state.draftIdByQuestion,
    ));
  }

  /// Submits the quiz attempt to the server. Triggered automatically when
  /// the user reaches [QuizPhase.finished], and can be re-invoked from the
  /// UI to retry on failure.
  Future<void> submit() async {
    final levelId = _levelId;
    if (levelId == null) return;
    if (state.isSubmitting) return;

    final answers = state.allQuestions
        .map(
          (q) => QuizAnswerSubmission(
            questionId: q.id,
            isCorrect: state.firstTryCorrectIds.contains(q.id),
          ),
        )
        .toList();
    final request = QuizSubmissionRequest(
      pointsEarned: state.points,
      answers: answers,
    );

    emit(
      state.copyWith(
        submissionStatus: SubmissionStatus.submitting,
        submissionError: () => null,
      ),
    );

    try {
      final result = await _quizRepository.submitQuiz(levelId, request);
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.success,
          submissionResult: () => result,
        ),
      );
    } on ServerException catch (e) {
      logger.error('QuizCubit.submit failed: ${e.message}');
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.error,
          submissionError: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('QuizCubit.submit failed: $e');
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.error,
          submissionError: () => 'errors.generic',
        ),
      );
    }
  }

  void _emitCorrect(int choiceId, QuestionModel question) {
    var pointsEarned = 0;
    var firstTryCorrect = state.firstTryCorrect;
    var firstTryCorrectIds = state.firstTryCorrectIds;
    if (state.round == 1) {
      firstTryCorrect++;
      pointsEarned = _scoreFor(_elapsedSinceShown());
      firstTryCorrectIds = {...firstTryCorrectIds, question.id};
    }
    emit(
      state.copyWith(
        phase: QuizPhase.answeredCorrect,
        selectedChoiceId: () => choiceId,
        firstTryCorrect: firstTryCorrect,
        firstTryCorrectIds: firstTryCorrectIds,
        points: state.points + pointsEarned,
        motivationalMessageKey: () => _messages.randomCorrect(),
      ),
    );

    final isLastInRound =
        state.currentIndex + 1 >= state.currentQueue.length;
    if (isLastInRound && state.retryQueue.isEmpty) {
      submit();
    }
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
    required Map<int, int> draftIdByQuestion,
  }) {
    final now = _now();
    final empty = questions.isEmpty;
    return QuizState(
      status: QuizStatus.loaded,
      phase: empty ? QuizPhase.finished : QuizPhase.question,
      allQuestions: questions,
      currentQueue: questions,
      savedQuestionIds: savedQuestionIds,
      draftIdByQuestion: draftIdByQuestion,
      startedAt: now,
      questionShownAt: empty ? null : now,
      elapsed: empty ? Duration.zero : null,
      motivationalMessageKey: empty ? _messages.randomFinish() : null,
    );
  }
}
