import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// The leaderboard title row. [trailing] holds an optional action pinned to the
/// end of the row (the country filter); the row keeps a fixed minimum height so
/// showing or hiding it doesn't shift the content below.
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 34),
      child: Row(
        children: [
          Expanded(
            child: ResponsiveText(
              'leaderboard.title'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 24,
                height: 1,
                letterSpacing: -0.3,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
