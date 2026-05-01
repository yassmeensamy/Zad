import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Canonical back-button used by both [ZaadAppBar] and the onboarding
/// top-nav. A 38×38 ivory disc with a soft olive-tinted border and a
/// chevron that points in the correct direction for the current locale
/// (left in LTR, right in RTL).
class ZaadBackButton extends StatelessWidget {
  const ZaadBackButton({
    super.key,
    required this.onTap,
    this.tooltip,
    this.size = 38,
    this.iconSize = 20,
  });

  final VoidCallback onTap;
  final String? tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final button = Material(
      color: colors.canvas.withValues(alpha: 0.6),
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
          width: size,
          height: size,
          child: Icon(
            isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            size: iconSize,
            color: colors.oliveDeep,
          ),
        ),
      ),
    );

    if (tooltip != null) return Tooltip(message: tooltip!, child: button);
    return button;
  }
}
