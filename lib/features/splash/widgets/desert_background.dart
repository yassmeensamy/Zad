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

  // Lighter cream stops from the Olive v2 design (linear-gradient 165deg).
  static const _ivoryLight = Color(0xFFF6EEDB);
  static const _sandLight = Color(0xFFECDCBC);
  static const _duneLight = Color(0xFFDFC79A);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base linear gradient: lighter cream stops (matches v2 design exactly).
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.3, -1),
              end: Alignment(0.3, 1),
              stops: [0.0, 0.5, 1.0],
              colors: [_ivoryLight, _sandLight, _duneLight],
            ),
          ),
        ),
        // Top-right amber radial glow @ 20%.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, -1),
              radius: 1.1,
              colors: [
                colors.accent.withValues(alpha: 0.20),
                colors.accent.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55],
            ),
          ),
        ),
        // Bottom-left olive radial glow @ 18% (was warm date — now matches design).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.6, 1),
              radius: 1.1,
              colors: [
                colors.olive.withValues(alpha: 0.18),
                colors.olive.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55],
            ),
          ),
        ),
        // Repeating Islamic pattern, multiply blend at 32% (untinted).
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(
                'assets/images/islamic-pattern.png',
                repeat: ImageRepeat.repeat,
                colorBlendMode: BlendMode.multiply,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        // Soft ivory radial veil to lift the centre (78% → 32% → 0%).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.7,
              colors: [
                _ivoryLight.withValues(alpha: 0.78),
                _ivoryLight.withValues(alpha: 0.32),
                _ivoryLight.withValues(alpha: 0),
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
