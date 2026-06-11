import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';

/// Shared canvas for the splash & auth screens: a diagonal gradient, two
/// amber/olive radial glows, a tiled Islamic-pattern overlay and a soft central
/// veil over the form area.
///
/// Every colour is read from [AppColorsTheme] tokens (the `desert*` family),
/// so the backdrop adapts to light/dark automatically — warm Desert Sand in
/// light, the roasted Date & Ember vignette in dark — without the widget
/// branching on brightness for colours. The one structural difference between
/// themes is the wallpaper compositing: the light tile is an opaque cream
/// pattern (multiply, edge-masked), while the dark tile is the near-white
/// line-art screened faintly over the canvas — mirroring `_NightDialogSurface`.
///
/// As the root canvas it also drives the status-bar icon brightness so screens
/// don't each declare their own [AnnotatedRegion]. Embedded uses that shouldn't
/// touch the system chrome (e.g. inside a dialog) pass `setSystemOverlay: false`.
class DesertBackground extends StatelessWidget {
  const DesertBackground({
    super.key,
    required this.child,
    this.setSystemOverlay = true,
  });

  final Widget child;

  /// Whether this canvas owns the system status-bar overlay style. True for
  /// full-screen usages; false when embedded (e.g. a dialog body).
  final bool setSystemOverlay;

  /// Alpha mask for the light-mode wallpaper: the pattern reads at the screen's
  /// top & bottom edges and fades out over the vertically-centred form area.
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
    // Structural only — selects the wallpaper asset + blend mode (a near-white
    // line-art must be *screened* onto the dark canvas, an opaque cream tile
    // *multiplied* onto the light one). All colours still come from tokens.
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        // Base diagonal gradient — warm cream in light, roasted brown in dark.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.3, -1),
              end: const Alignment(0.3, 1),
              stops: const [0.0, 0.5, 1.0],
              colors: [
                colors.desertGradientTop,
                colors.desertGradientMid,
                colors.desertGradientBottom,
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
        // Bottom-left olive radial glow @ 18%.
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
        // Tiled Islamic-pattern wallpaper.
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: isDark
                  ? Opacity(
                      // Faint ivory line-art screened over the dark canvas, to
                      // match the night dialog surface.
                      opacity: 0.05,
                      child: Image.asset(
                        'assets/images/islamic-pattern.png',
                        repeat: ImageRepeat.repeat,
                        alignment: Alignment.topLeft,
                        color: colors.desertPatternTint,
                        colorBlendMode: BlendMode.screen,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) =>
                          _patternMaskGradient.createShader(rect),
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
        // Soft veil over the form area so inputs read cleanly — a warm ivory
        // glow in light, a gentle raised-surface lift in dark.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.1),
              radius: 0.95,
              colors: [
                colors.desertVeil.withValues(alpha: 0.62),
                colors.desertVeil.withValues(alpha: 0.28),
                colors.desertVeil.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        child,
      ],
    );

    if (!setSystemOverlay) return stack;

    // Status-bar icons flip with the canvas: dark icons over the light sheet,
    // light icons over the roasted-brown night canvas.
    final overlay =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            );
    return AnnotatedRegion<SystemUiOverlayStyle>(value: overlay, child: stack);
  }
}
