import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Centered, italic hint used for empty podium / empty list states.
class LeaderboardEmptyHint extends StatelessWidget {
  const LeaderboardEmptyHint({
    super.key,
    required this.textKey,
    this.vertical = 0,
  });

  final String textKey;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Center(
        child: ResponsiveText(
          textKey.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Error message + retry action shown when the active list fails to load.
class LeaderboardErrorRetry extends StatelessWidget {
  const LeaderboardErrorRetry({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            'leaderboard.error'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: ResponsiveText(
              'common.retry'.tr(),
              style: AppTextStyles.labelLarge.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
