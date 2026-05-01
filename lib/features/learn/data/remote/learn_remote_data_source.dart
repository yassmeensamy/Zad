import 'package:flutter/material.dart';

import '../models/learn_category.dart';
import '../models/learn_level.dart';

abstract class LearnRemoteDataSource {
  Future<List<LearnCategory>> getCategories();
  Future<LearnCategory> getCategory(LearnCategoryId id);
  List<LearnCategory> getPlaceholders();
}

class LearnRemoteDataSourceImpl implements LearnRemoteDataSource {
  LearnRemoteDataSourceImpl();

  @override
  Future<List<LearnCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 450));
    return List.unmodifiable(_seed);
  }

  @override
  Future<LearnCategory> getCategory(LearnCategoryId id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _seed.firstWhere((c) => c.id == id);
  }

  @override
  List<LearnCategory> getPlaceholders() => _placeholders;

  static final List<LearnCategory> _seed = [
    LearnCategory(
      id: LearnCategoryId.companions,
      titleKey: 'learn.categories.companions.title',
      subtitleKey: 'learn.categories.companions.subtitle',
      icon: Icons.groups_2_outlined,
      levels: _buildLevels(
        'learn.categories.companions.levels',
        completed: 3,
        inProgressFraction: 0.45,
        total: 8,
      ),
    ),
    LearnCategory(
      id: LearnCategoryId.fiqh,
      titleKey: 'learn.categories.fiqh.title',
      subtitleKey: 'learn.categories.fiqh.subtitle',
      icon: Icons.balance_outlined,
      levels: _buildLevels(
        'learn.categories.fiqh.levels',
        completed: 1,
        inProgressFraction: 0.20,
        total: 6,
      ),
    ),
    LearnCategory(
      id: LearnCategoryId.hadith,
      titleKey: 'learn.categories.hadith.title',
      subtitleKey: 'learn.categories.hadith.subtitle',
      icon: Icons.auto_stories_outlined,
      levels: _buildLevels(
        'learn.categories.hadith.levels',
        completed: 5,
        inProgressFraction: 0.70,
        total: 7,
      ),
    ),
    LearnCategory(
      id: LearnCategoryId.quran,
      titleKey: 'learn.categories.quran.title',
      subtitleKey: 'learn.categories.quran.subtitle',
      icon: Icons.menu_book_outlined,
      levels: _buildLevels(
        'learn.categories.quran.levels',
        completed: 2,
        inProgressFraction: 0.55,
        total: 9,
      ),
    ),
    LearnCategory(
      id: LearnCategoryId.sharia,
      titleKey: 'learn.categories.sharia.title',
      subtitleKey: 'learn.categories.sharia.subtitle',
      icon: Icons.account_balance_outlined,
      levels: _buildLevels(
        'learn.categories.sharia.levels',
        completed: 0,
        inProgressFraction: 0.10,
        total: 6,
      ),
    ),
  ];

  static final List<LearnCategory> _placeholders =
      List<LearnCategory>.generate(6, (i) {
    return LearnCategory(
      id: LearnCategoryId.values[i % LearnCategoryId.values.length],
      titleKey: 'Category title',
      subtitleKey:
          'A short two-line description that hints at what this theme is about.',
      icon: Icons.menu_book_outlined,
      levels: List<LearnLevel>.generate(
        6,
        (j) => LearnLevel(
          index: j + 1,
          titleKey: 'Level title',
          descriptionKey: 'Level description',
          status: j < 2
              ? LearnLevelStatus.completed
              : j == 2
                  ? LearnLevelStatus.unlocked
                  : LearnLevelStatus.locked,
          progress: j < 2
              ? 1
              : j == 2
                  ? 0.45
                  : 0,
        ),
      ),
    );
  });

  static List<LearnLevel> _buildLevels(
    String baseKey, {
    required int completed,
    required double inProgressFraction,
    required int total,
  }) {
    return List.generate(total, (i) {
      final index = i + 1;
      final LearnLevelStatus status;
      final double progress;
      if (i < completed) {
        status = LearnLevelStatus.completed;
        progress = 1;
      } else if (i == completed) {
        status = LearnLevelStatus.unlocked;
        progress = inProgressFraction;
      } else {
        status = LearnLevelStatus.locked;
        progress = 0;
      }
      return LearnLevel(
        index: index,
        titleKey: '$baseKey.l$index.title',
        descriptionKey: '$baseKey.l$index.description',
        status: status,
        progress: progress,
      );
    });
  }
}
