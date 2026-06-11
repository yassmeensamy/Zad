import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// A centered section label flanked by two short fading rules (e.g. "PODIUM").
class PodiumEyebrow extends StatelessWidget {
  const PodiumEyebrow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _RuleSegment(toRight: true),
        const SizedBox(width: 10),
        ResponsiveText(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: 10),
        const _RuleSegment(toRight: false),
      ],
    );
  }
}

/// The "ALL MEMBERS (n)" divider above the full ranking list — a centered count
/// label flanked by two full-width fading rules.
class AllMembersRule extends StatelessWidget {
  const AllMembersRule({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0),
              colors.accent.withValues(alpha: 0.30),
              colors.accent.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 8),
        ResponsiveText(
          'leaderboard.all_members'
              .tr(namedArgs: {'count': '$count'})
              .toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        line,
      ],
    );
  }
}

class _RuleSegment extends StatelessWidget {
  const _RuleSegment({required this.toRight});

  final bool toRight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 26,
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: toRight
                ? [colors.accent.withValues(alpha: 0), colors.accent]
                : [colors.accent, colors.accent.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
