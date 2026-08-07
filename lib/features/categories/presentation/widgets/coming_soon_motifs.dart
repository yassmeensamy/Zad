import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/islamic_ornaments.dart';

/// Painters for the "coming soon" tile: its dashed edge, and the blooms that
/// sit behind its blur.
///
/// Drawn rather than shipped as assets so they inherit the theme's tint and
/// stay sharp at any density, and kept in the app's khatim-star vocabulary so
/// the tile still reads as part of the same family as the category cards.

/// Dashed rounded-rectangle outline. Marks the tile as provisional — the
/// category cards use a solid hairline, so a dashed edge reads as "not a real
/// category yet" without needing a word of copy.
class DashedRRectBorderPainter extends CustomPainter {
  const DashedRRectBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.2,
    this.dash = 5,
    this.gap = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the stroke so the dashes are not clipped in half by the
    // card's own antialiased rounded clip.
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    if (rect.isEmpty) return;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}

/// The shapes that sit *behind* the tile's blur. Painted crisp and hard-edged
/// on purpose; the [BackdropFilter] above turns them into soft blooms, which
/// is what sells the "there is light behind this veil" reading.
///
/// The rosette is centred on the hourglass medallion rather than on the card,
/// so the glow reads as coming from the icon. The two orbs sit low and wide,
/// clear of the copy — anything bright directly behind the text muddies it,
/// however soft the blur.
class GhostBloomPainter extends CustomPainter {
  const GhostBloomPainter({required this.tint, required this.warm});

  final Color tint;
  final Color warm;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas
      ..drawPath(
        khatimStarPath(Offset(w * 0.50, h * 0.34), size.shortestSide * 0.42),
        Paint()..color = tint,
      )
      ..drawCircle(Offset(w * 0.10, h * 0.12), w * 0.20, Paint()..color = warm)
      ..drawCircle(Offset(w * 0.92, h * 0.24), w * 0.16, Paint()..color = warm);
  }

  @override
  bool shouldRepaint(GhostBloomPainter old) =>
      old.tint != tint || old.warm != warm;
}
