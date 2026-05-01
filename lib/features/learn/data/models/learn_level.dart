import 'package:flutter/foundation.dart';

enum LearnLevelStatus { locked, unlocked, completed }

@immutable
class LearnLevel {
  const LearnLevel({
    required this.index,
    required this.titleKey,
    required this.descriptionKey,
    required this.status,
    this.progress = 0,
  }) : assert(progress >= 0 && progress <= 1);

  final int index;
  final String titleKey;
  final String descriptionKey;
  final LearnLevelStatus status;
  final double progress;

  bool get isLocked => status == LearnLevelStatus.locked;
  bool get isUnlocked => status == LearnLevelStatus.unlocked;
  bool get isCompleted => status == LearnLevelStatus.completed;
}
