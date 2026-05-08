import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Hand-painted flame matching the streak hero in `Zad Home v2`.
///
/// Renders an outer flame silhouette with a luminous inner core, wrapped in
/// a softly pulsing amber halo.
class StreakFlame extends StatefulWidget {
  const StreakFlame({super.key, this.size = 64});

  final double size;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with TickerProviderStateMixin {
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _flicker.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size;
    final h = widget.size * (78 / 64);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _pulse.value;
              final scale = 1.0 + 0.12 * t;
              final opacity = 0.55 + 0.45 * t;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: w + 44,
                  height: h + 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      radius: 0.5,
                      colors: [
                        AppColors.flameHalo
                            .withValues(alpha: 0.55 * opacity),
                        AppColors.flameHalo.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _flicker,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(w * (54 / 64), h * (68 / 78)),
                  painter: _FlamePainter(progress: _flicker.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.progress});

  final double progress;

  static const _outerRect = Rect.fromLTWH(0, 6, 64, 72);
  static const _innerRect = Rect.fromLTWH(22, 22, 20, 52);

  static const _outerStops = [
    AppColors.flameLight,
    AppColors.flameGold,
    AppColors.amber,
    AppColors.date,
  ];

  static final _innerStops = [
    AppColors.flameCore,
    AppColors.flameGold,
    AppColors.amber.withValues(alpha: 0.6),
  ];

  // Shaders depend only on rect (which is constant) and gradient colors —
  // cache once, reuse across every paint.
  static final Shader _outerShader = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _outerStops,
    stops: [0.0, 0.45, 0.78, 1.0],
  ).createShader(_outerRect);

  static final Shader _innerShader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _innerStops,
    stops: const [0.0, 0.6, 1.0],
  ).createShader(_innerRect);

  static final Path _outerPath = Path()
    ..moveTo(32, 4)
    ..cubicTo(38, 18, 50, 24, 52, 40)
    ..cubicTo(54, 56, 46, 70, 32, 74)
    ..cubicTo(18, 70, 10, 56, 12, 40)
    ..cubicTo(14, 28, 22, 22, 26, 12)
    ..cubicTo(28, 18, 30, 22, 32, 4)
    ..close();

  static final Path _innerPath = Path()
    ..moveTo(32, 22)
    ..cubicTo(36, 30, 42, 36, 42, 48)
    ..cubicTo(42, 60, 36, 68, 32, 70)
    ..cubicTo(28, 68, 22, 60, 22, 48)
    ..cubicTo(22, 38, 28, 32, 32, 22)
    ..close();

  static final Paint _outerStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..color = AppColors.date.withValues(alpha: 0.5);

  static final Paint _outerFillPaint = Paint()..shader = _outerShader;
  static final Paint _innerFillPaint = Paint()..shader = _innerShader;
  static final Paint _corePaint = Paint()
    ..color = AppColors.flameCore.withValues(alpha: 0.85);

  static const _coreRect = Rect.fromLTWH(26, 47, 12, 18);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 80);

    // Subtle flicker around the bottom of the flame.
    final phase = progress * 2 * math.pi;
    final sx = 1 + 0.04 * math.sin(phase);
    final sy = 1 - 0.02 * math.sin(phase + 1.2);
    canvas.translate(32, 80);
    canvas.scale(sx, sy);
    canvas.translate(-32, -80);

    // Outer flame body. (Glow comes from the parent _pulse halo — no
    // MaskFilter.blur here; that was the dominant per-frame cost.)
    canvas.drawPath(_outerPath, _outerFillPaint);
    canvas.drawPath(_outerPath, _outerStrokePaint);

    // Brighter inner flame + glowing core ellipse.
    canvas.drawPath(_innerPath, _innerFillPaint);
    canvas.drawOval(_coreRect, _corePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) =>
      // Sub-frame progress changes are visually imperceptible; throttle to
      // ~0.5% deltas to roughly halve repaint frequency.
      (old.progress - progress).abs() > 0.005;
}
