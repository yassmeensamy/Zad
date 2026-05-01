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
        // Repeating Islamic pattern, masked so it fades out where content
        // sits (vertically centred form area) and only reads at the screen's
        // top/bottom edges. Multiply blend keeps the warm tone.
        Positioned.fill(
          child: IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x59FFFFFF), // ~35% — visible at top
                  Color(0x14FFFFFF), // ~8%  — calm where form sits
                  Color(0x14FFFFFF), // ~8%
                  Color(0x40FFFFFF), // ~25% — hint at bottom
                ],
                stops: [0.0, 0.32, 0.72, 1.0],
              ).createShader(rect),
              child: Image.asset(
                'assets/images/ChatGPT Image May 1, 2026, 06_04_43 PM.png',
                repeat: ImageRepeat.repeat,
                colorBlendMode: BlendMode.multiply,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        // Soft ivory veil over the form area to ensure inputs read cleanly.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.1),
              radius: 0.95,
              colors: [
                _ivoryLight.withValues(alpha: 0.62),
                _ivoryLight.withValues(alpha: 0.28),
                _ivoryLight.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
