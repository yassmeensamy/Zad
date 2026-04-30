import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/profile_section.dart';
import '../../../../core/widgets/islamic_ornaments.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({super.key, required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasTrailingWidget = item.trailing != null;
    final hasTrailingText = item.trailingText != null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        splashColor: colors.accent.withValues(alpha: 0.08),
        highlightColor: colors.accent.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: hasTrailingWidget ? 6 : 12,
          ),
          child: Row(
            children: [
              _StarIcon(icon: item.icon, colors: colors),
              const SizedBox(width: 14),
              Expanded(
                child: ResponsiveText(
                  item.titleKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              if (hasTrailingText) ...[
                ResponsiveText(
                  item.trailingText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.accentDeep.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (hasTrailingWidget)
                item.trailing!
              else
                Icon(
                  isRtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.olive.withValues(alpha: 0.30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarIcon extends StatelessWidget {
  const _StarIcon({required this.icon, required this.colors});
  final IconData icon;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: KhatimStarPainter(
                fill: colors.accent.withValues(alpha: 0.06),
                stroke: colors.accent.withValues(alpha: 0.40),
                strokeWidth: 0.7,
              ),
            ),
          ),
          Icon(icon, size: 14, color: colors.oliveDeep),
        ],
      ),
    );
  }
}
