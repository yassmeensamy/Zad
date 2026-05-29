import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class AllMembersHeader extends StatelessWidget {
  const AllMembersHeader({super.key, required this.count});

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
              Colors.transparent,
              colors.oliveSoft.withValues(alpha: 0.28),
              Colors.transparent,
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
            letterSpacing: 3.4,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(width: 8),
        line,
      ],
    );
  }
}
