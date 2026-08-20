abstract class QuizPoints {
  static const Duration fastThreshold = Duration(seconds: 10);
  static const Duration mediumThreshold = Duration(seconds: 20);

  static const double fast = 3;
  static const double medium = 2;
  static const double slow = 1;

  static const double secondTry = 1;
  static const double thirdTry = 0.5;

  static const double wrongPenalty = 1;
  static const double perfectRunBonus = 5;

  static const double none = 0;
}
