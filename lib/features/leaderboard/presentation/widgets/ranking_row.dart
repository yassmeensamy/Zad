import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/widgets/team_disc.dart';

/// A single global-leaderboard row. Shared by the individual and team boards:
/// individuals pass the username, teams pass the team name plus a member-count
/// [subtitle]. The activity-status dot from the team-internal board is omitted
/// because the global ranking endpoints do not return it.
class RankingRow extends StatelessWidget {
  const RankingRow({
    super.key,
    required this.rank,
    required this.title,
    required this.completed,
    required this.total,
    this.subtitle,
    this.isMe = false,
  });

  final int rank;
  final String title;
  final int completed;
  final int total;

  /// Secondary line, e.g. "12 members" for a team row. When null only the
  /// completed/total line is shown.
  final String? subtitle;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPodium = rank <= 3;
    final accent = switch (rank) {
      1 => colors.accentDeep,
      2 => colors.olive,
      3 => AppColors.date,
      _ => colors.oliveSoft,
    };

    final decoration = isMe
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.amberSoft.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.amberDeep.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberDeep.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPodium
                  ? accent.withValues(alpha: 0.35)
                  : colors.oliveSoft.withValues(alpha: 0.12),
            ),
          );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMe ? 16 : 14),
      decoration: decoration,
      child: Row(
        children: [
          ResponsiveText(
            rank.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: isMe
                  ? AppColors.amberDeep
                  : isPodium
                  ? accent
                  : colors.oliveSoft,
            ),
          ),
          const SizedBox(width: 12),
          TeamDisc(
            seed: title,
            size: isMe ? 38 : 34,
            fontSize: isMe ? 15 : 14,
            borderColor: isMe ? AppColors.amberDeep : null,
            borderWidth: isMe ? 1.5 : 0,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  isMe ? '$title · You' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                    color: isMe ? AppColors.dateDeep : colors.oliveDeep,
                    letterSpacing: -0.1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                _MetaLine(
                  subtitle: subtitle,
                  completed: completed,
                  total: total,
                  isMe: isMe,
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const _YouPill(),
          ],
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.subtitle,
    required this.completed,
    required this.total,
    required this.isMe,
  });

  final String? subtitle;
  final int completed;
  final int total;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final levelsColor = isMe ? AppColors.dateDeep : colors.oliveSoft;
    return Row(
      children: [
        if (subtitle != null) ...[
          Flexible(
            child: ResponsiveText(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: levelsColor,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '·',
            style: TextStyle(
              fontSize: 11,
              color: colors.oliveSoft.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: ResponsiveText(
            '$completed / $total levels',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: levelsColor,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _YouPill extends StatelessWidget {
  const _YouPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.amber, AppColors.amberDeep],
      ),
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: AppColors.amberDeep.withValues(alpha: 0.35),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ResponsiveText(
      'YOU',
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: AppColors.creamLight,
        height: 1,
      ),
    ),
  );
}
