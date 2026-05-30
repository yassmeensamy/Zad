import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/level_model.dart';
import 'level_badge.dart';
import 'level_card.dart';

class LevelTimelineRow extends StatelessWidget {
  const LevelTimelineRow({
    super.key,
    required this.level,
    required this.tint,
    required this.isFirst,
    required this.isLast,
  });

  final LevelModel level;
  final Color tint;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // A Stack avoids IntrinsicHeight: the non-positioned Row sizes the stack
    // (driven by the card's height) and the connector line stretches to fill
    // it via top/bottom — no speculative layout pass per row.
    return Stack(
      children: [
        PositionedDirectional(
          start: 21,
          top: isFirst ? 28 : 0,
          bottom: isLast ? 28 : 0,
          child: Container(
            width: 2,
            color: level.isCompleted
                ? tint.withValues(alpha: 0.55)
                : colors.borderSubtle,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1,
                  child: LevelBadge(level: level, tint: tint),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: LevelCard(level: level, tint: tint),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
