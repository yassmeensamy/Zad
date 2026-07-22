import '../../../core/constants/quiz_points.dart';

abstract final class QuizScoring {
  static const Duration fastThreshold = QuizPoints.fastThreshold;

  static const double perfectRunBonus = QuizPoints.perfectRunBonus;
  static const double wrongPenalty = QuizPoints.wrongPenalty;

  static double correct({required int round, required Duration elapsed}) {
    if (round == 1) {
      if (elapsed < QuizPoints.fastThreshold) return QuizPoints.fast;
      if (elapsed < QuizPoints.mediumThreshold) return QuizPoints.medium;
      return QuizPoints.slow;
    }
    if (round == 2) return QuizPoints.secondTry;
    if (round == 3) return QuizPoints.thirdTry;
    return QuizPoints.none;
  }

  static bool isFast(Duration elapsed) => elapsed < QuizPoints.fastThreshold;

  static double maxFor(int questionCount) =>
      questionCount * QuizPoints.fast + QuizPoints.perfectRunBonus;

  static double floor(double points) =>
      points < QuizPoints.minTotal ? QuizPoints.minTotal : points;
}
