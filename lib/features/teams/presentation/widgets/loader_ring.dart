import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Amber arc spinning on a faint olive track, with a static 8-point star
/// glyph in the centre. Sized 64×64 by default.
class LoaderRing extends StatefulWidget {
  const LoaderRing({super.key, this.size = 64});

  final double size;

  @override
  State<LoaderRing> createState() => _LoaderRingState();
}

class _LoaderRingState extends State<LoaderRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _ctrl.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _RingPainter(
                    trackColor: colors.oliveDeep.withValues(alpha: 0.10),
                    arcColor: colors.accent,
                  ),
                ),
              );
            },
          ),
          Icon(Icons.star_outline_rounded, color: colors.accentDeep, size: 22),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.trackColor, required this.arcColor});

  final Color trackColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.10;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - stroke / 2,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawCircle(size.center(Offset.zero), rect.width / 2, trackPaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = arcColor;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.55, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.arcColor != arcColor || old.trackColor != trackColor;
}
