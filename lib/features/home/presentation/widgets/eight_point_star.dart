import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Decorative 8-point star formed by two overlapping squares rotated 45°.
/// Renders as an outline only — used as a faint ornament behind hero cards.
class EightPointStar extends StatelessWidget {
  const EightPointStar({
    super.key,
    this.size = 140,
    this.color = AppColors.amberGlow,
    this.opacity = 0.10,
    this.strokeWidth = 1.5,
  });

  final double size;
  final Color color;
  final double opacity;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EightPointStarPainter(
          color: color.withValues(alpha: opacity),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _EightPointStarPainter extends CustomPainter {
  _EightPointStarPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    final inset = size.width * 0.22;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    canvas.drawRect(rect, paint);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.7853981633974483);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EightPointStarPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
