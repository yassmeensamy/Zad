import 'dart:math';

class MotivationalMessages {
  MotivationalMessages({Random? random}) : _random = random ?? Random();

  final Random _random;

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

  String randomCorrect() => correctKeys[_random.nextInt(correctKeys.length)];

  String randomWrong() => wrongKeys[_random.nextInt(wrongKeys.length)];

  String randomFinish() => finishKeys[_random.nextInt(finishKeys.length)];
}
