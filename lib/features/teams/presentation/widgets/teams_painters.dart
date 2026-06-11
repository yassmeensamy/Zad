import 'package:flutter/material.dart';

/// Shared low-level painting primitives for the Teams feature, extracted to
/// remove copy-pasted painters across the team screens.

/// Four-point sparkle/twinkle glyph on a 24×24 design grid, scaled to the
/// paint [size]. Used as a static accent on the team home activity feed and,
/// animated, as the twinkles around the #1 celebration medallion.
class SparklePainter extends CustomPainter {
  const SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final path = Path()
      ..moveTo(12 * s, 2 * s)
      ..lineTo(14 * s, 9 * s)
      ..lineTo(21 * s, 12 * s)
      ..lineTo(14 * s, 15 * s)
      ..lineTo(12 * s, 22 * s)
      ..lineTo(10 * s, 15 * s)
      ..lineTo(3 * s, 12 * s)
      ..lineTo(10 * s, 9 * s)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.color != color;
}

/// Strokes a dashed circle of [radius] centred on [center] using [paint].
/// [dash]/[gap] are arc lengths in logical pixels. Shared by the create-success
/// medallion rings and the join-error keyhole rim.
void paintDashedCircle(
  Canvas canvas,
  Offset center,
  double radius, {
  required double dash,
  required double gap,
  required Paint paint,
}) {
  final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  for (final metric in path.computeMetrics()) {
    var d = 0.0;
    while (d < metric.length) {
      final next = (d + dash).clamp(0.0, metric.length);
      canvas.drawPath(metric.extractPath(d, next), paint);
      d = next + gap;
    }
  }
}
