import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

/// Eight-point star mark: amber ring around two overlapping rounded squares
/// (date + amber) with a small ivory core.
///
/// When [animation] is supplied, the mark animates in: ring scales from 0.6→1,
/// the two squares rotate from −20°/25° to 0°/45°, and the core pops to scale 1.
class ZaadLogoMark extends StatelessWidget {
  const ZaadLogoMark({
    super.key,
    this.size = 140,
    this.animation,
  });

  final double size;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final anim = animation;
    if (anim == null) {
      return _StaticMark(size: size);
    }
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => _AnimatedMark(size: size, t: anim.value),
    );
  }
}

class _StaticMark extends StatelessWidget {
  const _StaticMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return _AnimatedMark(size: size, t: 1);
  }
}

class _AnimatedMark extends StatelessWidget {
  const _AnimatedMark({required this.size, required this.t});

  final double size;
  final double t; // 0..1

  // Eased segments matching the CSS transition delays/durations.
  double _seg(double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    final v = (t - start) / (end - start);
    return Curves.easeOutCubic.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ringT = _seg(0.05, 0.5);
    final squareAT = _seg(0.25, 0.7);
    final squareBT = _seg(0.35, 0.8);
    final coreT = _seg(0.55, 0.9);

    final starSize = size * (64 / 140);
    final coreSize = size * (12 / 140);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Amber ring.
          Opacity(
            opacity: ringT,
            child: Transform.scale(
              scale: 0.6 + 0.4 * ringT,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.accent, width: 1),
                ),
              ),
            ),
          ),
          // Square A — date colour, settles at 0°.
          Opacity(
            opacity: squareAT,
            child: Transform.rotate(
              angle: (-20 * (1 - squareAT)) * 3.1415926535 / 180,
              child: Transform.scale(
                scale: 0.4 + 0.6 * squareAT,
                child: Container(
                  width: starSize,
                  height: starSize,
                  decoration: BoxDecoration(
                    color: colors.textArabic,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          ),
          // Square B — amber colour, settles at 45°.
          Opacity(
            opacity: squareBT,
            child: Transform.rotate(
              angle:
                  (25 + (45 - 25) * squareBT) * 3.1415926535 / 180,
              child: Transform.scale(
                scale: 0.4 + 0.6 * squareBT,
                child: Container(
                  width: starSize,
                  height: starSize,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          ),
          // Ivory core.
          Transform.scale(
            scale: coreT,
            child: Container(
              width: coreSize,
              height: coreSize,
              decoration: BoxDecoration(
                color: colors.canvas,
                borderRadius: BorderRadius.circular(coreSize * 0.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
