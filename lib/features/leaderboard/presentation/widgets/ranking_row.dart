import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'leaderboard_disc.dart';
import 'rank_seed.dart';

/// A single row in the full ranking list. Highlights the current user ("me")
/// with a warm accent gradient and border.
class RankingRow extends StatelessWidget {
  const RankingRow({super.key, required this.seed});

  final RankSeed seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMe = seed.isMe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMe
            ? LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.12),
                  colors.accent.withValues(alpha: 0.02),
                ],
              )
            : null,
        color: isMe ? null : colors.textPrimary.withValues(alpha: 0.024),
        border: Border.all(
          color: isMe
              ? colors.accent.withValues(alpha: 0.4)
              : colors.textPrimary.withValues(alpha: 0.05),
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
                fontWeight: FontWeight.w600,
                color: isMe ? colors.accent : colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          LeaderboardDisc(
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
                ResponsiveText(
                  isMe
                      ? 'leaderboard.name_you'.tr(
                          namedArgs: {'name': seed.name},
                        )
                      : seed.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: isMe ? colors.accentSoft : colors.textPrimary,
                  ),
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
              ResponsiveText(
                '${seed.completed}/${seed.total}',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? colors.accentSoft : colors.textPrimary,
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
