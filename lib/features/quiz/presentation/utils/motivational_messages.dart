import 'dart:math';

class MotivationalMessages {
  MotivationalMessages._();

  static const List<String> correctKeys = [
    'quiz.motivation.correct_1',
    'quiz.motivation.correct_2',
    'quiz.motivation.correct_3',
  ];

  static const List<String> wrongKeys = [
    'quiz.motivation.wrong_1',
    'quiz.motivation.wrong_2',
    'quiz.motivation.wrong_3',
  ];

  static const List<String> finishKeys = [
    'quiz.motivation.finish_1',
    'quiz.motivation.finish_2',
    'quiz.motivation.finish_3',
  ];

  static final Random _rng = Random();

  static String randomCorrect() => correctKeys[_rng.nextInt(correctKeys.length)];

  static String randomWrong() => wrongKeys[_rng.nextInt(wrongKeys.length)];

  static String randomFinish() => finishKeys[_rng.nextInt(finishKeys.length)];
}
