import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../theme/theme.dart';

/// Premium animated illustration — breathing halo + counter-rotating dashed
/// rings + orbiting sparks around a softly pulsing emblem. Everything is sized
/// relative to [size] so it scales cleanly between screens.
class TeamEmptyIllustration extends StatelessWidget {
  const TeamEmptyIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final halo = size * 1.1;
    final innerRing = size * 0.72;
    final emblem = size * 0.42;

    return SizedBox(
      width: size,
      height: size * 0.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: SizedBox(width: halo, height: halo)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 4200.ms,
                  curve: Curves.easeInOut,
                  builder: (_, t, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accent.withValues(alpha: 0.06 + 0.12 * t),
                          colors.accent.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
          ),
          RepaintBoundary(
            child: SizedBox(width: size, height: size)
                .animate(onPlay: (c) => c.repeat())
                .custom(
                  duration: 28.seconds,
                  builder: (_, t, _) => CustomPaint(
                    size: Size.square(size),
                    painter: _OuterOrbitPainter(
                      t: t,
                      ringColor: colors.oliveLeaf.withValues(alpha: 0.55),
                      sparkColor: colors.accent,
                      sparkHaloColor: colors.accent.withValues(alpha: 0.35),
                    ),
                  ),
                ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              size: Size.square(innerRing),
              painter: _DashedRingPainter(
                color: colors.accentDeep.withValues(alpha: 0.45),
                strokeWidth: 1.4,
                dash: 3,
                gap: 6,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(begin: 0, end: 1, duration: 18.seconds),
          ),
          Container(
            width: emblem,
            height: emblem,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.canvas, AppColors.sand],
              ),
              border: Border.all(color: colors.accentDeep, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: -6,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.groups_2_outlined,
              color: colors.oliveDeep,
              size: emblem * 0.45,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.96,
                end: 1.04,
                duration: 2600.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

/// Paints a dashed circle inscribed in the given size.
class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    final segment = dash + gap;
    final count = (circumference / segment).floor();
    final step = 2 * math.pi / count;
    final dashAngle = (dash / circumference) * 2 * math.pi;

    for (var i = 0; i < count; i++) {
      final start = i * step;
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          dashAngle,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}

/// Paints the outer dashed orbit (counter-clockwise) together with the four
/// sparks orbiting clockwise on the same circle. Both are driven by the same
/// `t` so they share one ticker and never drift.
class _OuterOrbitPainter extends CustomPainter {
  const _OuterOrbitPainter({
    required this.t,
    required this.ringColor,
    required this.sparkColor,
    required this.sparkHaloColor,
  });

  final double t;
  final Color ringColor;
  final Color sparkColor;
  final Color sparkHaloColor;

  static const double _strokeWidth = 1.4;
  static const double _dash = 6;
  static const double _gap = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = math.min(size.width, size.height) / 2 - _strokeWidth;
    final ringRect = Rect.fromCircle(center: center, radius: ringRadius);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-t * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    final circumference = 2 * math.pi * ringRadius;
    const segment = _dash + _gap;
    final count = (circumference / segment).floor();
    final step = 2 * math.pi / count;
    final dashAngle = (_dash / circumference) * 2 * math.pi;
    for (var i = 0; i < count; i++) {
      canvas.drawPath(
        Path()..addArc(ringRect, i * step, dashAngle),
        ringPaint,
      );
    }
    canvas.restore();

    final sparkRadius = math.min(size.width, size.height) / 2 - 2;
    final base = t * 2 * math.pi;
    final core = Paint()..color = sparkColor;
    final halo = Paint()
      ..color = sparkHaloColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (var i = 0; i < 4; i++) {
      final angle = base + i * (math.pi / 2);
      final dot = Offset(
        center.dx + sparkRadius * math.cos(angle),
        center.dy + sparkRadius * math.sin(angle),
      );
      canvas.drawCircle(dot, 5, halo);
      canvas.drawCircle(dot, 2.4, core);
    }
  }

  @override
  bool shouldRepaint(covariant _OuterOrbitPainter old) =>
      old.t != t ||
      old.ringColor != ringColor ||
      old.sparkColor != sparkColor ||
      old.sparkHaloColor != sparkHaloColor;
}
