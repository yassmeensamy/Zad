import 'package:flutter/foundation.dart';

import '../../core/quiz_scoring.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_submission_response.dart';

enum QuizStatus { initial, loading, loaded, error }

enum QuizPhase {
  question,
  answeredCorrect,
  answeredIncorrect,
  finished,
}

enum SubmissionStatus { idle, submitting, success, error }

class QuizHistoryEntry {
  const QuizHistoryEntry({
    required this.question,
    required this.choiceId,
    required this.round,
    this.fromPreviousAttempt = false,
  });

  final QuestionModel question;
  final int choiceId;
  final int round;

  /// Seeded at load for a question an earlier attempt already answered
  /// correctly: browsable and revealed, but not part of this attempt.
  final bool fromPreviousAttempt;

  bool get isCorrect => question.isCorrect(choiceId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizHistoryEntry &&
          other.question == question &&
          other.choiceId == choiceId &&
          other.round == round &&
          other.fromPreviousAttempt == fromPreviousAttempt;

  @override
  int get hashCode =>
      Object.hash(question, choiceId, round, fromPreviousAttempt);
}

class QuizState {
  const QuizState({
    this.status = QuizStatus.initial,
    this.phase = QuizPhase.question,
    this.allQuestions = const [],
    this.currentQueue = const [],
    this.retryQueue = const [],
    this.currentIndex = 0,
    this.selectedChoiceId,
    this.round = 1,
    this.firstTryCorrect = 0,
    this.answeredCorrectIds = const {},
    this.fastFirstTryIds = const {},
    this.totalRetries = 0,
    this.points = 0,
    this.isPerfectRun = true,
    this.perfectBonusAwarded = false,
    this.motivationalMessageKey,
    this.errorMessage,
    this.startedAt,
    this.questionShownAt,
    this.elapsed,
    this.submissionStatus = SubmissionStatus.idle,
    this.submissionResult,
    this.isReview = false,
    this.levelId,
    this.history = const [],
  });

  final QuizStatus status;
  final QuizPhase phase;
  final List<QuestionModel> allQuestions;
  final List<QuestionModel> currentQueue;
  final List<QuestionModel> retryQueue;
  final int currentIndex;
  final int? selectedChoiceId;
  final int round;
  final int firstTryCorrect;

  final Set<int> answeredCorrectIds;
  final Set<int> fastFirstTryIds;
  final int totalRetries;

  final double points;

  final bool isPerfectRun;

  final bool perfectBonusAwarded;
  final String? motivationalMessageKey;
  final String? errorMessage;

  final DateTime? startedAt;

  final DateTime? questionShownAt;

  final Duration? elapsed;

  final SubmissionStatus submissionStatus;
  final QuizSubmissionResponse? submissionResult;

  final bool isReview;

  final int? levelId;

  final List<QuizHistoryEntry> history;

  QuizState copyWith({
    QuizStatus? status,
    QuizPhase? phase,
    List<QuestionModel>? allQuestions,
    List<QuestionModel>? currentQueue,
    List<QuestionModel>? retryQueue,
    int? currentIndex,
    int? Function()? selectedChoiceId,
    int? round,
    int? firstTryCorrect,
    Set<int>? answeredCorrectIds,
    Set<int>? fastFirstTryIds,
    int? totalRetries,
    double? points,
    bool? isPerfectRun,
    bool? perfectBonusAwarded,
    String? Function()? motivationalMessageKey,
    String? errorMessage,
    DateTime? Function()? startedAt,
    DateTime? Function()? questionShownAt,
    Duration? Function()? elapsed,
    SubmissionStatus? submissionStatus,
    QuizSubmissionResponse? Function()? submissionResult,
    bool? isReview,
    int? levelId,
    List<QuizHistoryEntry>? history,
  }) =>
      QuizState(
        status: status ?? this.status,
        phase: phase ?? this.phase,
        allQuestions: allQuestions ?? this.allQuestions,
        currentQueue: currentQueue ?? this.currentQueue,
        retryQueue: retryQueue ?? this.retryQueue,
        currentIndex: currentIndex ?? this.currentIndex,
        selectedChoiceId: selectedChoiceId != null
            ? selectedChoiceId()
            : this.selectedChoiceId,
        round: round ?? this.round,
        firstTryCorrect: firstTryCorrect ?? this.firstTryCorrect,
        answeredCorrectIds: answeredCorrectIds ?? this.answeredCorrectIds,
        fastFirstTryIds: fastFirstTryIds ?? this.fastFirstTryIds,
        totalRetries: totalRetries ?? this.totalRetries,
        points: points ?? this.points,
        isPerfectRun: isPerfectRun ?? this.isPerfectRun,
        perfectBonusAwarded: perfectBonusAwarded ?? this.perfectBonusAwarded,
        motivationalMessageKey: motivationalMessageKey != null
            ? motivationalMessageKey()
            : this.motivationalMessageKey,
        errorMessage: errorMessage,
        startedAt: startedAt != null ? startedAt() : this.startedAt,
        questionShownAt: questionShownAt != null
            ? questionShownAt()
            : this.questionShownAt,
        elapsed: elapsed != null ? elapsed() : this.elapsed,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        submissionResult: submissionResult != null
            ? submissionResult()
            : this.submissionResult,
        isReview: isReview ?? this.isReview,
        levelId: levelId ?? this.levelId,
        history: history ?? this.history,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizState &&
        other.status == status &&
        other.phase == phase &&
        listEquals(other.allQuestions, allQuestions) &&
        listEquals(other.currentQueue, currentQueue) &&
        listEquals(other.retryQueue, retryQueue) &&
        other.currentIndex == currentIndex &&
        other.selectedChoiceId == selectedChoiceId &&
        other.round == round &&
        other.firstTryCorrect == firstTryCorrect &&
        setEquals(other.answeredCorrectIds, answeredCorrectIds) &&
        setEquals(other.fastFirstTryIds, fastFirstTryIds) &&
        other.totalRetries == totalRetries &&
        other.points == points &&
        other.isPerfectRun == isPerfectRun &&
        other.perfectBonusAwarded == perfectBonusAwarded &&
        other.motivationalMessageKey == motivationalMessageKey &&
        other.errorMessage == errorMessage &&
        other.startedAt == startedAt &&
        other.questionShownAt == questionShownAt &&
        other.elapsed == elapsed &&
        other.submissionStatus == submissionStatus &&
        other.submissionResult == submissionResult &&
        other.isReview == isReview &&
        other.levelId == levelId &&
        listEquals(other.history, history);
  }

  @override
  int get hashCode => Object.hash(
        status,
        phase,
        Object.hashAll(allQuestions),
        Object.hashAll(currentQueue),
        Object.hashAll(retryQueue),
        currentIndex,
        selectedChoiceId,
        round,
        firstTryCorrect,
        Object.hash(
          Object.hashAllUnordered(answeredCorrectIds),
          Object.hashAllUnordered(fastFirstTryIds),
        ),
        totalRetries,
        Object.hash(points, isPerfectRun, perfectBonusAwarded),
        motivationalMessageKey,
        errorMessage,
        Object.hash(startedAt, questionShownAt, elapsed),
        Object.hash(submissionStatus, submissionResult),
        isReview,
        levelId,
        Object.hashAll(history),
      );
}

extension QuizStateX on QuizState {
  bool get isInitial => status == QuizStatus.initial;
  bool get isLoading => status == QuizStatus.loading;
  bool get isLoaded => status == QuizStatus.loaded;
  bool get isError => status == QuizStatus.error;

  bool get isFinished => phase == QuizPhase.finished;
  bool get isAnswered =>
      phase == QuizPhase.answeredCorrect ||
      phase == QuizPhase.answeredIncorrect;
  bool get isCorrect => phase == QuizPhase.answeredCorrect;

  bool get isSubmitting => submissionStatus == SubmissionStatus.submitting;
  bool get isSubmitted => submissionStatus == SubmissionStatus.success;
  bool get isSubmissionError => submissionStatus == SubmissionStatus.error;

  QuestionModel? get currentQuestion {
    if (currentQueue.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= currentQueue.length) return null;
    return currentQueue[currentIndex];
  }

  int get totalQuestions => allQuestions.length;

  /// Every question the user has tapped an answer for in this attempt, right or
  /// wrong. Questions carried over from an earlier attempt are excluded.
  Set<int> get answeredIds => {
        for (final entry in history)
          if (!entry.fromPreviousAttempt) entry.question.id,
      };

  int get positionInRound => currentQueue.isEmpty ? 0 : currentIndex + 1;
  int get roundLength => currentQueue.length;

  double get maxPoints => QuizScoring.maxFor(totalQuestions);

  int get pointsRounded => points.round();

  bool get isLastInCurrentRound =>
      currentQueue.isNotEmpty && currentIndex + 1 >= currentQueue.length;
}
