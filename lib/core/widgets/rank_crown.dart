import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Small golden crown drawn above the first-place avatar on a podium.
///
/// Palette-independent (uses const [AppColors] directly), so it renders the
/// same in any feature. Shared by the leaderboard podium and the team home
/// podium.
class RankCrown extends StatelessWidget {
  const RankCrown({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 16,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 26;
    final sy = size.height / 16;
    final path = Path()
      ..moveTo(1.5 * sx, 14 * sy)
      ..lineTo(4 * sx, 5 * sy)
      ..lineTo(9.5 * sx, 10.5 * sy)
      ..lineTo(13 * sx, 2.5 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(22 * sx, 5 * sy)
      ..lineTo(24.5 * sx, 14 * sy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.discGoldHi, AppColors.discGoldLo],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.discGoldLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
