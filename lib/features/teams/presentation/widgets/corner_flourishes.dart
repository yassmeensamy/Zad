import 'package:flutter/material.dart';

/// Tiny L-shaped corner flourishes painted at all four corners of the
/// parent, anchoring the gilded invite chip on the Decree screen and the
/// error chip on the Join screen.
///
/// Designed to sit inside a `Stack` next to the chip container — uses
/// `Positioned.fill` internally so it stretches to the chip's bounds.
class CornerFlourishes extends StatelessWidget {
  const CornerFlourishes({
    super.key,
    required this.color,
    this.arm = 6.0,
    this.inset = -1.0,
    this.strokeWidth = 1.3,
  });

  final Color color;
  final double arm;
  final double inset;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CornerPainter(
            color: color,
            arm: arm,
            inset: inset,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.color,
    required this.arm,
    required this.inset,
    required this.strokeWidth,
  });

  final Color color;
  final double arm;
  final double inset;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.square;

    // Top-left.
    canvas.drawLine(
      Offset(inset, inset + arm),
      Offset(inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, inset),
      Offset(inset + arm, inset),
      paint,
    );
    // Top-right.
    canvas.drawLine(
      Offset(size.width - inset - arm, inset),
      Offset(size.width - inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + arm),
      paint,
    );
    // Bottom-left.
    canvas.drawLine(
      Offset(inset, size.height - inset - arm),
      Offset(inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + arm, size.height - inset),
      paint,
    );
    // Bottom-right.
    canvas.drawLine(
      Offset(size.width - inset - arm, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      old.color != color ||
      old.arm != arm ||
      old.inset != inset ||
      old.strokeWidth != strokeWidth;
}
