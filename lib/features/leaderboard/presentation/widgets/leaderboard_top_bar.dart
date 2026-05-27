import 'package:flutter/material.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../theme/theme.dart';

class LeaderboardTopBar extends StatelessWidget {
  const LeaderboardTopBar({
    super.key,
    required this.teamName,
    required this.joinCode,
  });

  final String teamName;
  final String joinCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText(
                'League · Daʿwah Tier'.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                  color: colors.oliveDeep.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 18,
                  color: colors.oliveDeep,
                  height: 1,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (innerContext) => ZaadCircleIconButton.share(
            onTap: () => sl<ShareService>().shareFrom(
              context: innerContext,
              text:
                  'Join "$teamName" on Zaad! Use code $joinCode to climb the leaderboard with us.',
              subject: 'Join my Zaad team',
            ),
          ),
        ),
      ],
    );
  }
}
