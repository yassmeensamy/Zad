import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Standard close-affordance for dialogs and bottom sheets:
/// 30×30 ivory circle with a soft olive-tinted border, centred close glyph.
/// Designed to sit at the top-end corner of a [CustomDialog] body.
class ZaadCloseButton extends StatelessWidget {
  const ZaadCloseButton({
    super.key,
    required this.onTap,
    this.enabled = true,
    this.size = 30,
    this.iconSize = 14,
  });

  final VoidCallback onTap;
  final bool enabled;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.canvas.withValues(alpha: 0.6),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            size: iconSize,
            color: colors.oliveDeep,
          ),
        ),
      ),
    );
  }
}
