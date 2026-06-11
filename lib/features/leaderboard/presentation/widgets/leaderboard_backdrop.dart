import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Warm radial canvas behind the leaderboard: a vignette gradient, a faint
/// tiled Islamic pattern, a top glow and a drift of rising embers. [child] is
/// painted on top of all the decorative layers.
class LeaderboardBackdrop extends StatelessWidget {
  const LeaderboardBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1.05),
          radius: 1.35,
          colors: [
            colors.backdropTop,
            colors.backdropMid,
            colors.backdropBottom,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.06,
                child: Image(
                  image: const AssetImage('assets/images/islamic-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  color: isDark ? colors.textPrimary : colors.textTertiary,
                  colorBlendMode: isDark
                      ? BlendMode.screen
                      : BlendMode.multiply,
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            right: -120,
            top: -120,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [
                      colors.accent.withValues(alpha: isDark ? 0.22 : 0.16),
                      colors.accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _EmberField(core: colors.accentSoft, glow: colors.accent),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _EmberField extends StatefulWidget {
  const _EmberField({required this.core, required this.glow});

  final Color core;
  final Color glow;

  @override
  State<_EmberField> createState() => _EmberFieldState();
}

class _EmberFieldState extends State<_EmberField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

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
        painter: _EmberPainter(
          sparks: _sparks,
          t: _c.value,
          core: widget.core,
          glow: widget.glow,
        ),
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
  _EmberPainter({
    required this.sparks,
    required this.t,
    required this.core,
    required this.glow,
  });
  final List<_Spark> sparks;
  final double t;
  final Color core;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      final p = (t / s.durScale + s.phase) % 1.0;
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
            core.withValues(alpha: opacity),
            glow.withValues(alpha: opacity * 0.6),
            glow.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.core != core ||
      oldDelegate.glow != glow;
}
