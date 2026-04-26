import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

/// Desert Sand background: linear gradient + two amber/date radial glows,
/// repeating Islamic pattern overlay, and a soft ivory radial veil.
///
/// Wrap any screen content in this widget to get the same canvas as the
/// splash and login designs.
class DesertBackground extends StatelessWidget {
  const DesertBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base linear gradient: ivory -> sand -> dune.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.3, -1),
              end: const Alignment(0.3, 1),
              stops: const [0.0, 0.45, 1.0],
              colors: [
                colors.canvas,
                colors.canvasRaised,
                AppColors.dune,
              ],
            ),
          ),
        ),
        // Top-right amber radial glow.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, -1),
              radius: 1.1,
              colors: [
                colors.accent.withValues(alpha: 0.28),
                colors.accent.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55],
            ),
          ),
        ),
        // Bottom-left date radial glow.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.6, 1),
              radius: 1.1,
              colors: [
                colors.textArabic.withValues(alpha: 0.22),
                colors.textArabic.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55],
            ),
          ),
        ),
        // Repeating Islamic pattern (multiply blend, ~0.45 opacity).
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/islamic-pattern.png',
                repeat: ImageRepeat.repeat,
                color: colors.textArabic.withValues(alpha: 0.55),
                colorBlendMode: BlendMode.multiply,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        // Soft ivory radial veil to lift the centre.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.7,
              colors: [
                colors.canvas.withValues(alpha: 0.7),
                colors.canvas.withValues(alpha: 0.25),
                colors.canvas.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
