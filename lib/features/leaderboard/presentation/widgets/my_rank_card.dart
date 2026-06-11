import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// The sticky "your rank" / "your team" card at the bottom of the leaderboard.
/// Reads as a warm ember highlight in dark and a gilded gold card in light.
class MyRankCard extends StatelessWidget {
  const MyRankCard({
    super.key,
    required this.label,
    required this.rank,
    required this.title,
    required this.completed,
    required this.total,
    this.onTap,
  });

  final String label;
  final int rank;
  final String title;
  final int completed;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;

    // Dark mode reads as a warm ember highlight. In light, the same cta (olive)
    // tokens washed out to a muddy grey-green over the cream page, so we gild
    // the card instead — a soft gold gradient, a crisp amber hairline and a
    // lighter warm lift — echoing the leaderboard's gold-medal motif. The olive
    // rank badge then pops against it.
    final bgGradient = isDark
        ? [
            colors.ctaMid.withValues(alpha: 0.18),
            colors.ctaBottom.withValues(alpha: 0.08),
          ]
        : [
            colors.accent.withValues(alpha: 0.22),
            colors.accentSoft.withValues(alpha: 0.12),
          ];
    final borderColor = isDark
        ? colors.ctaTop.withValues(alpha: 0.4)
        : colors.accent.withValues(alpha: 0.5);
    final shadow = isDark
        ? BoxShadow(
            color: colors.heroShadow.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 16),
          )
        : BoxShadow(
            color: colors.accent.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          );
    // Deeper amber for the eyebrow + chevron so they keep contrast on the
    // warmer light card (plain accent would blend into the gold wash).
    final accentInk = isDark ? colors.accent : colors.accentDeep;

    final card = Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: bgGradient,
        ),
        border: Border.all(color: borderColor),
        boxShadow: [shadow],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.ctaTop, colors.ctaMid],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.ctaMid.withValues(alpha: 0.55),
                  blurRadius: 14,
                ),
              ],
            ),
            child: ResponsiveText(
              '#$rank',
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.onCta,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                    color: accentInk,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: ResponsiveText(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ResponsiveText(
                      'leaderboard.levels_progress'.tr(
                        namedArgs: {
                          'completed': '$completed',
                          'total': '$total',
                        },
                      ),
                      maxLines: 1,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward, size: 15, color: accentInk),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      ),
    );
  }
}
