import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class HomeVerseCard extends StatelessWidget {
  const HomeVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.olive.withValues(alpha: 0.10),
            colors.olive.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: colors.olive.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveText(
            'WORD FOR THE DAY',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 8.5 * 0.26,
              color: colors.olive,
            ),
          ),
          const SizedBox(height: 7),
          ResponsiveText(
            'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              height: 1.7,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          ResponsiveText(
            '"Indeed, with hardship comes ease." — Ash-Sharḥ 94:6',
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
