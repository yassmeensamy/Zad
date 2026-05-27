import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/data/models/member_activity_status_enum.dart';
import '../../../teams/data/models/team_member_progress_model.dart';
import '../../../teams/presentation/widgets/team_disc.dart';

class ClimbTile extends StatelessWidget {
  const ClimbTile({
    super.key,
    required this.rank,
    required this.member,
    this.isMe = false,
  });

  final int rank;
  final TeamMemberProgressModel member;
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
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isMe ? 16 : 14,
      ),
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
            seed: member.username,
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
                  isMe ? '${member.username} · You' : member.username,
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
                _StatusLine(
                  status: member.activityStatus,
                  completed: member.completedLevels,
                  total: member.totalLevels,
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

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.status,
    required this.completed,
    required this.total,
    required this.isMe,
  });

  final MemberActivityStatus status;
  final int completed;
  final int total;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tone = _toneFor(status, colors);
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tone,
            boxShadow: [
              BoxShadow(
                color: tone.withValues(alpha: 0.45),
                blurRadius: 5,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        ResponsiveText(
          status.label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: tone,
            height: 1.1,
            letterSpacing: 0.2,
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
        Flexible(
          child: ResponsiveText(
            '$completed / $total levels',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: isMe ? AppColors.dateDeep : colors.oliveSoft,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Color _toneFor(MemberActivityStatus s, AppColorsTheme colors) => switch (s) {
        MemberActivityStatus.active => colors.success,
        MemberActivityStatus.consistent => AppColors.amberDeep,
        MemberActivityStatus.idle => colors.oliveSoft,
      };
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
