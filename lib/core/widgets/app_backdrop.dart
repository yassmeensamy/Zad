import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/date_ember_palette.dart';

/// The app-wide **Date & Ember** background for dark mode.
///
/// A roasted-brown radial vignette (raised → surface → base) with a tiled
/// Islamic-pattern wallpaper, a warm amber wash glowing from the top edge and
/// rising ember sparks.
///
/// It is injected once behind the whole app via `MaterialApp.builder`, so every
/// dark screen shares it. Scaffolds are transparent in dark mode (see
/// `AppTheme`), letting this show through. It is purely decorative — every layer
/// ignores pointers.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        // radial-gradient(130% 75% at 50% -8%, #271A10, #1A120B 42%, #0E0905)
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.05),
            radius: 1.4,
            colors: [DateEmber.raised, DateEmber.surface, DateEmber.base],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Tiled Islamic-pattern wallpaper, screened over the canvas.
            Opacity(
              opacity: 0.05,
              child: Image(
                image: AssetImage('assets/images/islamic-pattern.png'),
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topLeft,
                color: DateEmber.ivory,
                colorBlendMode: BlendMode.screen,
              ),
            ),
            // Warm amber wash near the top.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.95),
                  radius: 0.9,
                  colors: [Color(0x29E1A560), Color(0x00E1A560)],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
            // Rising ember sparks.
            _EmberField(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rising ember particle field.
// ─────────────────────────────────────────────────────────────────────────────
class _EmberField extends StatefulWidget {
  const _EmberField();

  @override
  State<_EmberField> createState() => _EmberFieldState();
}

class _EmberFieldState extends State<_EmberField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 13),
  )..repeat();

  // Deterministic per-particle parameters (no Random at paint time).
  final List<_Spark> _sparks = List.generate(14, (i) {
    final rnd = math.Random(i * 7 + 3);
    return _Spark(
      x: rnd.nextDouble(),
      durScale: 0.5 + rnd.nextDouble(),
      sizeScale: 0.5 + rnd.nextDouble() * 0.9,
      phase: rnd.nextDouble(),
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _EmberPainter(sparks: _sparks, t: _c.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.x,
    required this.durScale,
    required this.sizeScale,
    required this.phase,
  });
  final double x;
  final double durScale;
  final double sizeScale;
  final double phase;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.sparks, required this.t});
  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      final p = (t / s.durScale + s.phase) % 1.0;
      // Opacity envelope: fade in, hold, fade out (mirrors the CSS keyframes).
      double opacity;
      if (p < 0.12) {
        opacity = (p / 0.12) * 0.7;
      } else if (p < 0.85) {
        opacity = 0.7 - (p - 0.12) / 0.73 * 0.3;
      } else {
        opacity = 0.4 * (1 - (p - 0.85) / 0.15);
      }
      if (opacity <= 0) continue;

      final scale = 0.5 + p * 0.7;
      final radius = 2 * s.sizeScale * scale;
      final dx = s.x * size.width;
      final dy = size.height - p * (size.height + 40);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            DateEmber.amberLight.withValues(alpha: opacity),
            DateEmber.emberLight.withValues(alpha: opacity * 0.6),
            DateEmber.emberLight.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
