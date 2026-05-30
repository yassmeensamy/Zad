import 'package:flutter/material.dart';

import 'islamic_ornaments.dart';

/// An 8-point Khatim star outline used as a tinted badge behind an icon or
/// label. Wraps the painter in a [RepaintBoundary] so it does not repaint
/// when surrounding content (e.g. a scrolling card) changes.
class StarMedallion extends StatelessWidget {
  const StarMedallion({
    super.key,
    required this.size,
    required this.tint,
    this.strokeWidth = 0.9,
    this.child,
  });

  final double size;
  final Color tint;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: KhatimStarPainter(
                  fill: tint.withValues(alpha: 0.10),
                  stroke: tint.withValues(alpha: 0.55),
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
