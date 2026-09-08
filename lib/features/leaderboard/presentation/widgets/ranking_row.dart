import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_format.dart';
import '../../../../core/widgets/medal_disc.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'rank_seed.dart';

/// A single row in the full ranking list. Highlights the current user ("me")
/// with a warm accent gradient and border.
class RankingRow extends StatelessWidget {
  const RankingRow({super.key, required this.seed});

  final RankSeed seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;
    final isMe = seed.isMe;

    // Your own row carried a 12%→2% amber wash, which all but vanished against
    // the list; the fill, hairline and border weight are all raised so it reads
    // as the pinned row it is. The amber ink follows: `accentSoft` holds up on
    // the dark wash but sat around 1.5:1 on the light cream one, so light drops
    // to the deeper amber.
    final meInk = isDark ? colors.accentSoft : colors.accentDeep;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMe
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.accent.withValues(alpha: isDark ? 0.26 : 0.30),
                  colors.accent.withValues(alpha: isDark ? 0.10 : 0.14),
                ],
              )
            : null,
        color: isMe ? null : colors.textPrimary.withValues(alpha: 0.024),
        border: Border.all(
          color: isMe
              ? colors.accent.withValues(alpha: 0.7)
              : colors.textPrimary.withValues(alpha: 0.05),
          width: isMe ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: ResponsiveText(
              seed.rank.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                color: isMe ? meInk : colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          MedalDisc(
            size: 38,
            initial: discInitial(seed.name),
            style: discStyleForRow(seed.rank, isMe),
            fontSize: 15,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (seed.flag case final flag? when flag.isNotEmpty) ...[
                      ResponsiveText(
                        flag,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 13.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: ResponsiveText(
                        isMe
                            ? 'leaderboard.name_you'.tr(
                                namedArgs: {'name': seed.name},
                              )
                            : seed.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                          height: 1.1,
                          color: isMe ? meInk : colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ResponsiveText(
                  _metaLine(seed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Points lead the trailing column for individuals. The level
              // count moved out rather than doubling up — the meta line under
              // the name already spells out "x of y levels".
              if (seed.points case final points?)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Amber on every row, not just your own: the star is the
                    // unit marker here, not a highlight.
                    Icon(Icons.stars_rounded, size: 13, color: meInk),
                    const SizedBox(width: 3),
                    ResponsiveText(
                      groupedNumber(context, points),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                        color: isMe ? meInk : colors.textPrimary,
                      ),
                    ),
                  ],
                )
              else
                ResponsiveText(
                  '${seed.completed}/${seed.total}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                    color: isMe ? meInk : colors.textPrimary,
                  ),
                ),
              const SizedBox(height: 2),
              ResponsiveText(
                '${seed.percent}%',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _metaLine(RankSeed seed) {
    final levels = 'leaderboard.levels_progress'.tr(
      namedArgs: {'completed': '${seed.completed}', 'total': '${seed.total}'},
    );
    final sub = seed.subtitle;
    return sub == null ? levels : '$sub · $levels';
  }
}
