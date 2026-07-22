import '../../../../core/constants/quiz_points.dart';
import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../support_tickets/data/models/create_ticket_request.dart';
import '../../../support_tickets/data/models/support_topic_enum.dart';
import '../../../support_tickets/data/repositories/support_tickets_repository.dart';
import '../../../offline/data/models/pending_answer_input.dart';
import '../../core/quiz_event_service.dart';
import '../../core/quiz_scoring.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_submission_request.dart';
import '../../data/repositories/quiz_repository.dart';
import '../utils/motivational_messages.dart';
import 'quiz_state.dart';

class QuizCubit extends BaseCubit<QuizState> {
  QuizCubit({
    required QuizRepository quizRepository,
    required QuizEventService quizEventService,
    required SupportTicketsRepository supportTicketsRepository,
    DateTime Function() now = DateTime.now,
    MotivationalMessages? messages,
  })  : _quizRepository = quizRepository,
        _events = quizEventService,
        _supportTickets = supportTicketsRepository,
        _now = now,
        _messages = messages ?? MotivationalMessages(),
        super(const QuizState());

  final QuizRepository _quizRepository;
  final QuizEventService _events;
  final SupportTicketsRepository _supportTickets;
  final DateTime Function() _now;
  final MotivationalMessages _messages;

  Future<void> loadQuiz(int levelId, {bool review = false}) async {
    emit(state.copyWith(
      status: QuizStatus.loading,
      isReview: review,
      levelId: levelId,
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

  void reviewBack() {
    if (!state.isReview) return;
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void restart() {
    if (state.allQuestions.isEmpty) return;
    emit(_buildLoadedState(state.allQuestions, review: false));
  }

  Future<bool> reportQuestion({
    required int questionId,
    required String title,
    required String body,
  }) async {
    try {
      await _supportTickets.createTicket(
        CreateTicketRequest(
          topic: SupportTopicEnum.technical,
          title: title,
          body: body,
          questionId: questionId,
        ),
      );
      return true;
    } on ServerException catch (e) {
      logger.error('QuizCubit.reportQuestion failed: ${e.message}');
      return false;
    } catch (e) {
      logger.error('QuizCubit.reportQuestion failed: $e');
      return false;
    }
  }

  Future<void> submit() async {
    final levelId = state.levelId;
    if (levelId == null || state.isSubmitting) return;

    final request = QuizSubmissionRequest(
      pointsEarned: state.pointsRounded,
      answers: [
        for (final q in state.allQuestions)
          QuizAnswerSubmission(
            questionId: q.id,
            isCorrect: state.answeredCorrectIds.contains(q.id),
          ),
      ],
    );

    final firstRoundChoice = <int, int>{};
    for (final entry in state.history) {
      if (entry.round == 1) {
        firstRoundChoice.putIfAbsent(entry.question.id, () => entry.choiceId);
      }
    }
    final selectedAnswers = [
      for (final q in state.allQuestions)
        PendingAnswerInput(
          questionId: q.id,
          selectedAnswer: firstRoundChoice[q.id] ?? -1,
          isCorrect: state.answeredCorrectIds.contains(q.id),
        ),
    ];

    emit(state.copyWith(
      submissionStatus: SubmissionStatus.submitting,
    ));

    try {
      final result = await _quizRepository.submitQuiz(
        levelId,
        request,
        selectedAnswers: selectedAnswers,
      );
      emit(state.copyWith(
        submissionStatus: SubmissionStatus.success,
        submissionResult: () => result,
      ));
      _events.notifySubmitted(levelId);
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
    final elapsed = _elapsedSinceShown();
    final earned = QuizScoring.correct(round: state.round, elapsed: elapsed);
    final firstTryCorrect =
        isFirstTry ? state.firstTryCorrect + 1 : state.firstTryCorrect;

    final stillPerfect =
        state.isPerfectRun && isFirstTry && QuizScoring.isFast(elapsed);

    final isAttemptComplete =
        state.isLastInCurrentRound && state.retryQueue.isEmpty;
    final earnsBonus = isAttemptComplete &&
        stillPerfect &&
        firstTryCorrect == state.totalQuestions;

    emit(state.copyWith(
      phase: QuizPhase.answeredCorrect,
      selectedChoiceId: () => choiceId,
      firstTryCorrect: firstTryCorrect,
      answeredCorrectIds: {...state.answeredCorrectIds, question.id},
      points: QuizScoring.floor(
        state.points +
            earned +
            (earnsBonus ? QuizPoints.perfectRunBonus : QuizPoints.none),
      ),
      isPerfectRun: stillPerfect,
      perfectBonusAwarded: earnsBonus,
      motivationalMessageKey: () => _messages.randomCorrect(),
      history: _appendHistory(question, choiceId),
    ));

    if (isAttemptComplete) {
      submit();
    }
  }

  void _emitIncorrect(int choiceId, QuestionModel question) {
    emit(state.copyWith(
      phase: QuizPhase.answeredIncorrect,
      selectedChoiceId: () => choiceId,
      retryQueue: [...state.retryQueue, question],
      totalRetries: state.totalRetries + 1,
      points: QuizScoring.floor(state.points - QuizPoints.wrongPenalty),
      isPerfectRun: false,
      motivationalMessageKey: () => _messages.randomWrong(),
      history: _appendHistory(question, choiceId),
    ));
  }

  List<QuizHistoryEntry> _appendHistory(QuestionModel question, int choiceId) =>
      [
        ...state.history,
        QuizHistoryEntry(
          question: question,
          choiceId: choiceId,
          round: state.round,
        ),
      ];

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
      levelId: state.levelId,
    );
  }

  void _emitLoadError(String? message) {
    emit(state.copyWith(
      status: QuizStatus.error,
      errorMessage: message,
    ));
  }

  void _emitSubmitError(String? message) {
    emit(state.copyWith(
      submissionStatus: SubmissionStatus.error,
      errorMessage: message,
    ));
  }
}
