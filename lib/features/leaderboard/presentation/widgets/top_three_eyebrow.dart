import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class TopThreeEyebrow extends StatelessWidget {
  const TopThreeEyebrow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 18,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, colors.accentDeep],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ResponsiveText(
          'leaderboard.top_three'.tr().toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontFamily: 'monospace',
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: colors.accentDeep,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.star_rounded, size: 10, color: colors.accentDeep),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.accentDeep, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
