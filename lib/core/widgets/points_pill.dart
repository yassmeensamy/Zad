import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../utils/number_format.dart';
import 'responsive_text.dart';

/// The account's running points total, as a gold pill: star, grouped figure,
/// localised unit. Shared by the profile hero and the home greeting so the
/// balance reads identically wherever it surfaces.
///
/// Callers decide whether to show it at all — guests have no server-side
/// balance, so their zero is hidden rather than rendered.
class PointsPill extends StatelessWidget {
  const PointsPill({super.key, required this.points, this.dense = false});

  final int points;

  /// Tighter padding and type, for sitting inline under the home greeting
  /// where the full-size pill would crowd the header.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Same split the leaderboard rows make: the deep amber holds contrast on
    // the cream card, but goes muddy on the dark one, where the soft tone reads.
    final starInk = context.isDark ? colors.accentSoft : colors.accentDeep;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 4 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.pillAll,
        color: colors.accent.withValues(alpha: 0.14),
        border: Border.all(color: colors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, size: dense ? 13 : 16, color: starInk),
          SizedBox(width: dense ? 5 : 6),
          ResponsiveText(
            'common.total_points',
            args: [groupedNumber(context, points)],
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: dense ? 11.5 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}
