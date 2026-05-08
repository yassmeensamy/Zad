import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Amber-tinted CTA strip that prompts the user to join a team and compete
/// with friends. Sits between the streak hero and the hadith section.
class JoinTeamCard extends StatelessWidget {
  const JoinTeamCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.creamSurfaceTop, colors.creamSurfaceBottom],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accentDeep.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const _TeamIcon(),
              const SizedBox(width: 14),
              const Expanded(child: _TeamMeta()),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.olive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamIcon extends StatelessWidget {
  const _TeamIcon();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.accent, colors.accentDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accentDeep.withValues(alpha: 0.32),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.groups_rounded,
        size: 22,
        color: colors.canvas,
      ),
    );
  }
}

class _TeamMeta extends StatelessWidget {
  const _TeamMeta();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home.team.eyebrow'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 9 * 0.32,
            color: colors.accentDeep,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'home.team.title_prefix'.tr(),
              style: AppTextStyles.bodyXLarge.copyWith(
                color: colors.oliveDeep,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
            Text(
              'home.team.title_accent'.tr(),
              style: AppTextStyles.bodyXLarge.copyWith(
                color: colors.textArabic,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'home.team.subtitle'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.dateSoft,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
