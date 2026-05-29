import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Amber-tinted card pinned beneath the list that always surfaces the
/// authenticated user's own standing — their individual rank or their team's
/// rank — even when that row is not on the currently loaded page.
class MyRankCard extends StatelessWidget {
  const MyRankCard({
    super.key,
    required this.label,
    required this.rank,
    required this.title,
    required this.completed,
    required this.total,
  });

  /// Eyebrow above the card, e.g. "YOUR RANK" or "YOUR TEAM".
  final String label;
  final int rank;
  final String title;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.amberSoft.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amberDeep.withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amberDeep.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResponsiveText(
                label.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppColors.amberDeep,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                '#$rank',
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dateDeep,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            width: 1,
            height: 34,
            color: AppColors.amberDeep.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.oliveDeep,
                  ),
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  '$completed / $total levels',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.dateDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
