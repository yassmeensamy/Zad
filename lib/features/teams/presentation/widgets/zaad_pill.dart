import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

enum ZaadPillTone { amber, olive, oliveOnDark, green, red, ivory }

/// Small uppercase pill used across team screens (e.g. `Leader`, `#14 / 312`).
class ZaadPill extends StatelessWidget {
  const ZaadPill({
    super.key,
    required this.label,
    this.tone = ZaadPillTone.olive,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontSize = 9,
  });

  final String label;
  final ZaadPillTone tone;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (bg, fg, border) = switch (tone) {
      ZaadPillTone.amber => (
        const LinearGradient(
          colors: [AppColors.amber, AppColors.amberDeep],
        ),
        colors.canvas,
        null,
      ),
      ZaadPillTone.olive => (
        LinearGradient(
          colors: [
            colors.olive.withValues(alpha: 0.16),
            colors.olive.withValues(alpha: 0.16),
          ],
        ),
        colors.oliveDeep,
        null,
      ),
      ZaadPillTone.oliveOnDark => (
        LinearGradient(
          colors: [colors.olive, colors.olive],
        ),
        colors.canvas,
        null,
      ),
      ZaadPillTone.green => (
        LinearGradient(
          colors: [
            colors.success.withValues(alpha: 0.18),
            colors.success.withValues(alpha: 0.18),
          ],
        ),
        colors.success,
        colors.success.withValues(alpha: 0.3),
      ),
      ZaadPillTone.red => (
        LinearGradient(
          colors: [colors.warningSurface, colors.warningSurface],
        ),
        const Color(0xFFB5564A),
        null,
      ),
      ZaadPillTone.ivory => (
        LinearGradient(
          colors: [
            colors.canvas.withValues(alpha: 0.14),
            colors.canvas.withValues(alpha: 0.14),
          ],
        ),
        colors.canvas,
        colors.canvas.withValues(alpha: 0.18),
      ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: ZaadRadii.pillAll,
        border: border != null ? Border.all(color: border) : null,
      ),
      child: ResponsiveText(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}
