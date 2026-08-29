import 'package:flutter/material.dart';

import '../../../categories/data/models/category_model.dart';
import '../cubit/levels_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import 'coming_soon_level_row.dart';
import 'level_timeline_row.dart';
import 'levels_hero.dart';

class LevelsList extends StatelessWidget {
  const LevelsList({
    super.key,
    this.controller,
    required this.state,
    required this.tint,
    this.category,
    this.allowComingSoon = true,
  });

  final ScrollController? controller;
  final LevelsState state;
  final Color tint;
  final CategoryModel? category;

  /// Whether this category is still getting new levels. Categories that are
  /// already complete pass `false` so the rail ends on the last real level
  /// rather than promising more.
  final bool allowComingSoon;

  static const _headerSlot = 0;
  static const _dividerSlot = 1;
  static const _firstRowIndex = 2;

  @override
  Widget build(BuildContext context) {
    final levels = state.levels;
    final showLoadingTail = state.isLoadingMore;
    // One trailing slot after the levels, holding whichever of the two ends the
    // rail: the pagination spinner while more pages are coming, or the "coming
    // soon" row once the last page is in. Never both, so they share the slot —
    // and a category that is already finished ends on neither.
    final showComingSoon =
        allowComingSoon && !showLoadingTail && !state.hasMore;
    final itemCount =
        _firstRowIndex +
        levels.length +
        (showLoadingTail || showComingSoon ? 1 : 0);

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _headerSlot) {
          return LevelsHero(state: state, tint: tint, category: category);
        }
        if (index == _dividerSlot) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: StarRule(color: tint, starSize: 10),
          );
        }
        final rowIndex = index - _firstRowIndex;
        if (rowIndex < levels.length) {
          final level = levels[rowIndex];
          return LevelTimelineRow(
            key: ValueKey(level.id),
            level: level,
            tint: tint,
            isFirst: rowIndex == 0,
            // The "coming soon" row takes over as the rail's end, so the last
            // real level keeps its connector running down into it.
            isLast: rowIndex == levels.length - 1 && !showComingSoon,
          );
        }
        if (showComingSoon) {
          return ComingSoonLevelRow(tint: tint);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: tint),
            ),
          ),
        );
      },
    );
  }
}
