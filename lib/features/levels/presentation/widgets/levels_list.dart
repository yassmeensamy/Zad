import 'package:flutter/material.dart';

import '../../../categories/data/models/category_model.dart';
import '../cubit/levels_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import 'level_timeline_row.dart';
import 'levels_hero.dart';

class LevelsList extends StatelessWidget {
  const LevelsList({
    super.key,
    this.controller,
    required this.state,
    required this.tint,
    this.category,
  });

  final ScrollController? controller;
  final LevelsState state;
  final Color tint;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final levels = state.levels;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      physics: const BouncingScrollPhysics(),
      children: [
        LevelsHero(state: state, tint: tint, category: category),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StarRule(color: tint, starSize: 10),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < levels.length; i++)
          LevelTimelineRow(
            level: levels[i],
            tint: tint,
            isFirst: i == 0,
            isLast: i == levels.length - 1,
          ),
        if (state.isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: tint),
              ),
            ),
          ),
      ],
    );
  }
}
