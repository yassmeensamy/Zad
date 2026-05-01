import 'package:flutter/material.dart';

import 'learn_level.dart';

enum LearnCategoryId { companions, fiqh, hadith, quran, sharia }

@immutable
class LearnCategory {
  const LearnCategory({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.levels,
  });

  final LearnCategoryId id;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final List<LearnLevel> levels;

  int get completedLevels =>
      levels.where((l) => l.status == LearnLevelStatus.completed).length;

  int get totalLevels => levels.length;

  double get progress {
    if (levels.isEmpty) return 0;
    final partial = levels.fold<double>(0, (sum, l) => sum + l.progress);
    return (partial / levels.length).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();
}
