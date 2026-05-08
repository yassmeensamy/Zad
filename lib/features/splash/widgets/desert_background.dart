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

  static final LinearGradient _patternMaskGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.white.withValues(alpha: 0.35),
      AppColors.white.withValues(alpha: 0.08),
      AppColors.white.withValues(alpha: 0.08),
      AppColors.white.withValues(alpha: 0.25),
    ],
    stops: const [0.0, 0.32, 0.72, 1.0],
  );

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
              colors: [
                AppColors.ivoryLight,
                AppColors.sandLight,
                AppColors.duneLight,
              ],
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
            child: RepaintBoundary(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => _patternMaskGradient.createShader(rect),
                child: Image.asset(
                  'assets/images/ChatGPT Image May 1, 2026, 06_04_43 PM.png',
                  repeat: ImageRepeat.repeat,
                  colorBlendMode: BlendMode.multiply,
                  filterQuality: FilterQuality.medium,
                ),
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
                AppColors.ivoryLight.withValues(alpha: 0.62),
                AppColors.ivoryLight.withValues(alpha: 0.28),
                AppColors.ivoryLight.withValues(alpha: 0),
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
