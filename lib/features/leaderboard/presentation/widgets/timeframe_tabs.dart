import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/data/models/leaderboard_timeframe_enum.dart';

class TimeframeTabs extends StatelessWidget {
  const TimeframeTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LeaderboardTimeframe value;
  final ValueChanged<LeaderboardTimeframe> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.oliveDeep.withValues(alpha: 0.08),
        borderRadius: ZaadRadii.pillAll,
        border: Border.all(
          color: colors.oliveSoft.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          for (final t in LeaderboardTimeframe.values)
            Expanded(
              child: _TimeframeChip(
                label: t.label,
                selected: t == value,
                onTap: () => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeframeChip extends StatelessWidget {
  const _TimeframeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [colors.oliveDeep, colors.olive],
                )
              : null,
          borderRadius: ZaadRadii.pillAll,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.oliveDeep.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ResponsiveText(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: selected
                ? AppColors.creamLight
                : colors.oliveDeep.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
