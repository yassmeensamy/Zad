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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: isFirst ? 28 : 0,
                      bottom: isLast ? 28 : 0,
                    ),
                    child: Center(
                      child: Container(
                        width: 2,
                        color: level.isCompleted
                            ? tint.withValues(alpha: 0.55)
                            : colors.borderSubtle,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: LevelBadge(level: level, tint: tint),
                ),
              ],
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
    );
  }
}
