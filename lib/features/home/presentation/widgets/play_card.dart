import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Olive-filled primary CTA that launches the quiz flow. Sits above the
/// amber-tinted [JoinTeamCard] as the home screen's main call to action.
class PlayCard extends StatelessWidget {
  const PlayCard({super.key, this.onTap});

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
              colors: [colors.ctaTop, colors.ctaMid, colors.ctaBottom],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.ctaBottom.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const _PlayIcon(),
              const SizedBox(width: 14),
              const Expanded(child: _PlayMeta()),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onCta.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayIcon extends StatelessWidget {
  const _PlayIcon();

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
            color: colors.ctaBottom.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.extension_rounded,
        size: 24,
        color: colors.canvas,
      ),
    );
  }
}

class _PlayMeta extends StatelessWidget {
  const _PlayMeta();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'home.play.eyebrow',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // tracking 0.288 == the prior 9 * 0.32 over the default size 10.
          style: AppTextStyles.eyebrow(
            tracking: 0.288,
            weight: FontWeight.w600,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveText(
              'home.play.title_prefix',
              style: AppTextStyles.bodyXLarge.copyWith(
                color: colors.onCta,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
            ResponsiveText(
              'home.play.title_accent',
              style: AppTextStyles.bodyXLarge.copyWith(
                color: colors.accent,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          'home.play.subtitle',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onCta.withValues(alpha: 0.75),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
