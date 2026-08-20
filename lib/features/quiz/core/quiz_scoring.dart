import '../../../core/constants/quiz_points.dart';

abstract final class QuizScoring {
  static const Duration fastThreshold = QuizPoints.fastThreshold;

  static const double perfectRunBonus = QuizPoints.perfectRunBonus;
  static const double wrongPenalty = QuizPoints.wrongPenalty;

  /// Points for finally answering correctly on [attempt], counting every wrong
  /// answer the question has taken — including ones recorded by an earlier,
  /// abandoned run of the same level. Only a true first attempt is worth full
  /// value, and only there does speed count.
  static double correct({required int attempt, required Duration elapsed}) {
    if (attempt <= 1) {
      if (elapsed < QuizPoints.fastThreshold) return QuizPoints.fast;
      if (elapsed < QuizPoints.mediumThreshold) return QuizPoints.medium;
      return QuizPoints.slow;
    }
    if (attempt == 2) return QuizPoints.secondTry;
    if (attempt == 3) return QuizPoints.thirdTry;
    return QuizPoints.none;
  }

  static bool isFast(Duration elapsed) => elapsed < QuizPoints.fastThreshold;

  static double maxFor(int questionCount) =>
      questionCount * QuizPoints.fast + QuizPoints.perfectRunBonus;
}
