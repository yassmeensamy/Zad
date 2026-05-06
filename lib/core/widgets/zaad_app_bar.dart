import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';
import 'zaad_circle_button.dart';

class ZaadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZaadAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.action,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ColoredBox(
      color: colors.canvas,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (onBack != null)
                  ZaadCircleIconButton.back(onTap: onBack!)
                else
                  const SizedBox(width: 38),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ResponsiveText(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZaadType.appBarTitle.copyWith(
                          color: colors.oliveDeep,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        ResponsiveText(
                          subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZaadType.appBarSubtitle.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null)
                  action!
                else
                  const SizedBox(width: 38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZaadAppBarIconButton extends StatelessWidget {
  const ZaadAppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconSize = 18,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final button = Material(
      color: Colors.white.withValues(alpha: 0.6),
      shape: CircleBorder(
        side: BorderSide(
          color: colors.olive.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: iconSize, color: colors.oliveDeep),
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: button);
    return button;
  }
}
