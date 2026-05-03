import 'package:flutter/foundation.dart';

import '../../data/models/question_model.dart';

enum QuizStatus { initial, loading, loaded, error }

enum QuizPhase {
  question,
  answeredCorrect,
  answeredIncorrect,
  finished,
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
    this.totalRetries = 0,
    this.savedQuestionIds = const {},
    this.motivationalMessageKey,
    this.errorMessage,
    this.startedAt,
    this.elapsed,
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
  final int totalRetries;
  final Set<int> savedQuestionIds;
  final String? motivationalMessageKey;
  final String? errorMessage;

  /// Timestamp captured the moment the quiz becomes loaded with the first
  /// question — i.e. when the user can start answering.
  final DateTime? startedAt;

  /// Total time from [startedAt] to the moment the user reaches the
  /// finished phase. Set once on transition to [QuizPhase.finished].
  final Duration? elapsed;

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
    int? totalRetries,
    Set<int>? savedQuestionIds,
    String? Function()? motivationalMessageKey,
    String? Function()? errorMessage,
    DateTime? Function()? startedAt,
    Duration? Function()? elapsed,
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
        totalRetries: totalRetries ?? this.totalRetries,
        savedQuestionIds: savedQuestionIds ?? this.savedQuestionIds,
        motivationalMessageKey: motivationalMessageKey != null
            ? motivationalMessageKey()
            : this.motivationalMessageKey,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
        startedAt: startedAt != null ? startedAt() : this.startedAt,
        elapsed: elapsed != null ? elapsed() : this.elapsed,
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
        other.totalRetries == totalRetries &&
        setEquals(other.savedQuestionIds, savedQuestionIds) &&
        other.motivationalMessageKey == motivationalMessageKey &&
        other.errorMessage == errorMessage &&
        other.startedAt == startedAt &&
        other.elapsed == elapsed;
  }

  @override
  int get hashCode => Object.hashAll([
        status,
        phase,
        Object.hashAll(allQuestions),
        Object.hashAll(currentQueue),
        Object.hashAll(retryQueue),
        currentIndex,
        selectedChoiceId,
        round,
        firstTryCorrect,
        totalRetries,
        Object.hashAll(savedQuestionIds),
        motivationalMessageKey,
        errorMessage,
        startedAt,
        elapsed,
      ]);
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

  QuestionModel? get currentQuestion {
    if (currentQueue.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= currentQueue.length) return null;
    return currentQueue[currentIndex];
  }

  bool isQuestionSaved(int questionId) =>
      savedQuestionIds.contains(questionId);

  int get totalQuestions => allQuestions.length;
  int get completedQuestions => totalQuestions; // every question is shown until correct

  /// Position within the current round (1-indexed) for the segmented progress.
  int get positionInRound => currentQueue.isEmpty ? 0 : currentIndex + 1;
  int get roundLength => currentQueue.length;

  /// Score: 10 points per first-try correct answer.
  int get points => firstTryCorrect * 10;
  int get maxPoints => totalQuestions * 10;
}
