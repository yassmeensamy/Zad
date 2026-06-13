import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Eight-pointed star (khatim) — the foundational rosette of Islamic
/// geometric design. Used here as a decorative medallion that frames
/// menu icons and punctuates ornamental rules.
class KhatimStarPainter extends CustomPainter {
  const KhatimStarPainter({
    required this.fill,
    required this.stroke,
    this.strokeWidth = 1.0,
    this.fillOpacity = 1.0,
  });

  final Color fill;
  final Color stroke;
  final double strokeWidth;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final path = _starPath(center, r);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = fill.withValues(alpha: fill.a * fillOpacity),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
    );
  }

  Path _starPath(Offset c, double r) {
    final path = Path();
    const points = 16; // 8 outer + 8 inner alternating vertices
    for (var i = 0; i < points; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? r : r * 0.62;
      final p = Offset(
        c.dx + radius * math.cos(angle),
        c.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(KhatimStarPainter old) =>
      old.fill != fill ||
      old.stroke != stroke ||
      old.strokeWidth != strokeWidth ||
      old.fillOpacity != fillOpacity;
}

/// Hairline gold rule with a centred khatim star — the punctuation
/// between hero and content, and between section header and card.
class StarRule extends StatelessWidget {
  const StarRule({
    super.key,
    required this.color,
    this.starSize = 10,
    this.thickness = 0.8,
  });

  final Color color;
  final double starSize;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final faint = color.withValues(alpha: 0.35);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: thickness,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0), faint],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: starSize,
            height: starSize,
            child: CustomPaint(
              painter: KhatimStarPainter(
                fill: color.withValues(alpha: 0.18),
                stroke: color.withValues(alpha: 0.7),
                strokeWidth: 0.7,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: thickness,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [faint, color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
