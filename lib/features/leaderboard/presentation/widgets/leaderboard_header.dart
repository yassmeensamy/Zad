import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// The leaderboard eyebrow + title block at the top of the screen.
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        ResponsiveText(
          'leaderboard.eyebrow'.tr().toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 4),
        ResponsiveText(
          'leaderboard.title'.tr(),
          style: AppTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            height: 1,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
