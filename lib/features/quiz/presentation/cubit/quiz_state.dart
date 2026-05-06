import 'package:flutter/foundation.dart';

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
    this.firstTryCorrectIds = const {},
    this.totalRetries = 0,
    this.points = 0,
    this.savedQuestionIds = const {},
    this.draftIdByQuestion = const {},
    this.savingQuestionIds = const {},
    this.motivationalMessageKey,
    this.errorMessage,
    this.startedAt,
    this.questionShownAt,
    this.elapsed,
    this.submissionStatus = SubmissionStatus.idle,
    this.submissionResult,
    this.submissionError,
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

  /// Question ids the user answered correctly on their first attempt
  /// (round 1). Used to mark `isCorrect` per question on submission.
  final Set<int> firstTryCorrectIds;
  final int totalRetries;

  /// Accumulated score. 2 points if a question is answered correctly within
  /// 10 seconds on the first try, 1 point otherwise on the first try, 0 if
  /// the first attempt is wrong (no points on retries).
  final int points;
  final Set<int> savedQuestionIds;

  /// Maps question id → server-assigned draft id, for questions the user has
  /// saved as drafts. Used to delete the right draft when un-saving.
  final Map<int, int> draftIdByQuestion;

  /// Question ids whose draft is currently being created or deleted on the
  /// server. Used to avoid double-tapping the save action.
  final Set<int> savingQuestionIds;
  final String? motivationalMessageKey;
  final String? errorMessage;

  /// Timestamp captured the moment the quiz becomes loaded with the first
  /// question — i.e. when the user can start answering.
  final DateTime? startedAt;

  /// Timestamp captured every time a new question becomes visible. Used to
  /// score the answer based on how fast the user reacted.
  final DateTime? questionShownAt;

  /// Total time from [startedAt] to the moment the user reaches the
  /// finished phase. Set once on transition to [QuizPhase.finished].
  final Duration? elapsed;

  final SubmissionStatus submissionStatus;
  final QuizSubmissionResponse? submissionResult;
  final String? submissionError;

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
    Set<int>? firstTryCorrectIds,
    int? totalRetries,
    int? points,
    Set<int>? savedQuestionIds,
    Map<int, int>? draftIdByQuestion,
    Set<int>? savingQuestionIds,
    String? Function()? motivationalMessageKey,
    String? Function()? errorMessage,
    DateTime? Function()? startedAt,
    DateTime? Function()? questionShownAt,
    Duration? Function()? elapsed,
    SubmissionStatus? submissionStatus,
    QuizSubmissionResponse? Function()? submissionResult,
    String? Function()? submissionError,
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
        firstTryCorrectIds: firstTryCorrectIds ?? this.firstTryCorrectIds,
        totalRetries: totalRetries ?? this.totalRetries,
        points: points ?? this.points,
        savedQuestionIds: savedQuestionIds ?? this.savedQuestionIds,
        draftIdByQuestion: draftIdByQuestion ?? this.draftIdByQuestion,
        savingQuestionIds: savingQuestionIds ?? this.savingQuestionIds,
        motivationalMessageKey: motivationalMessageKey != null
            ? motivationalMessageKey()
            : this.motivationalMessageKey,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
        startedAt: startedAt != null ? startedAt() : this.startedAt,
        questionShownAt: questionShownAt != null
            ? questionShownAt()
            : this.questionShownAt,
        elapsed: elapsed != null ? elapsed() : this.elapsed,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        submissionResult: submissionResult != null
            ? submissionResult()
            : this.submissionResult,
        submissionError:
            submissionError != null ? submissionError() : this.submissionError,
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
        setEquals(other.firstTryCorrectIds, firstTryCorrectIds) &&
        other.totalRetries == totalRetries &&
        other.points == points &&
        setEquals(other.savedQuestionIds, savedQuestionIds) &&
        mapEquals(other.draftIdByQuestion, draftIdByQuestion) &&
        setEquals(other.savingQuestionIds, savingQuestionIds) &&
        other.motivationalMessageKey == motivationalMessageKey &&
        other.errorMessage == errorMessage &&
        other.startedAt == startedAt &&
        other.questionShownAt == questionShownAt &&
        other.elapsed == elapsed &&
        other.submissionStatus == submissionStatus &&
        other.submissionResult == submissionResult &&
        other.submissionError == submissionError;
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
        Object.hashAllUnordered(firstTryCorrectIds),
        totalRetries,
        points,
        Object.hashAllUnordered(savedQuestionIds),
        Object.hashAll(draftIdByQuestion.entries.map((e) => Object.hash(e.key, e.value))),
        Object.hashAllUnordered(savingQuestionIds),
        motivationalMessageKey,
        errorMessage,
        Object.hash(startedAt, questionShownAt, elapsed),
        Object.hash(submissionStatus, submissionResult, submissionError),
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

  bool isQuestionSaved(int questionId) =>
      savedQuestionIds.contains(questionId);

  bool isQuestionSaving(int questionId) =>
      savingQuestionIds.contains(questionId);

  int get totalQuestions => allQuestions.length;
  int get completedQuestions => totalQuestions; // every question is shown until correct

  /// Position within the current round (1-indexed) for the segmented progress.
  int get positionInRound => currentQueue.isEmpty ? 0 : currentIndex + 1;
  int get roundLength => currentQueue.length;

  /// Maximum possible score: 2 points per question (achieved if every
  /// question is answered correctly within 10 seconds on the first try).
  int get maxPoints => totalQuestions * 2;
}
