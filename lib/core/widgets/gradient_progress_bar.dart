import 'package:flutter/material.dart';

/// A pill-shaped progress track with a gradient-filled bar. Shared by the
/// categories overview header and the per-category cards so both render an
/// identical bar from a single implementation.
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
    this.height = 6,
  });

  /// 0..1 fill fraction. Values outside the range are clamped.
  final double progress;
  final Color trackColor;
  final List<Color> gradientColors;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Stack(
        children: [
          Container(height: height, color: trackColor),
          FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
