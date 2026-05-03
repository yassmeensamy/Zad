import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Half-circle gauge painter used by [ResultView].
///
/// Draws a track arc, a sweep-gradient progress arc with a blurred glow halo,
/// 21 fading tick marks on the inside of the arc, and an endpoint dot at the
/// progress tip. Geometry is size-relative — the painter scales with its
/// container. Anchors the chord near the bottom of the canvas; the apex curves
/// toward the top.
class GaugePainter extends CustomPainter {
  const GaugePainter({
    required this.progress,
    required this.ticksProgress,
    required this.endpointVisible,
    required this.scoreFraction,
    required this.trackColor,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.tickColor,
    required this.endpointFill,
    required this.endpointStroke,
    required this.glowColor,
  });

  /// 0..1 — how far the progress arc has drawn (already includes scoreFraction).
  final double progress;
  final double ticksProgress;
  final double endpointVisible;
  final double scoreFraction;

  final Color trackColor;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color tickColor;
  final Color endpointFill;
  final Color endpointStroke;
  final Color glowColor;

  static const _stroke = 8.0;
  static const _tickCount = 21;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = (size.width / 2) - 20;
    final cy = size.height - 12;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    if (progress > 0) {
      final sweep = math.pi * progress;
      final shader = SweepGradient(
        startAngle: math.pi,
        endAngle: math.pi + math.pi,
        colors: [gradientStart, gradientMid, gradientEnd],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

      // Soft outer glow under the arc
      final glow = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = glowColor.withValues(alpha: 0.35);
      canvas.drawArc(rect, math.pi, sweep, false, glow);

      final prog = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, math.pi, sweep, false, prog);
    }

    if (ticksProgress > 0) {
      for (var i = 0; i < _tickCount; i++) {
        // Stagger: each tick reaches full opacity 0.04 of the timeline after
        // the previous, normalized into [0, 1] for ticksProgress.
        final t = i / (_tickCount - 1);
        final tickStart = (i * 0.04).clamp(0.0, 1.0);
        final localT = ((ticksProgress - tickStart) / (1 - tickStart)).clamp(
          0.0,
          1.0,
        );
        if (localT <= 0) continue;
        final angle = math.pi - t * math.pi; // 180° → 0°
        final inner = Offset(
          cx + math.cos(angle) * (r - 12),
          cy - math.sin(angle) * (r - 12),
        );
        final outer = Offset(
          cx + math.cos(angle) * (r - 4),
          cy - math.sin(angle) * (r - 4),
        );
        final paint = Paint()
          ..color = tickColor.withValues(alpha: tickColor.a * localT)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(inner, outer, paint);
      }
    }

    if (endpointVisible > 0) {
      final tipAngle = math.pi - scoreFraction * math.pi;
      final tip = Offset(
        cx + math.cos(tipAngle) * r,
        cy - math.sin(tipAngle) * r,
      );
      final fill = Paint()
        ..color = endpointFill.withValues(alpha: endpointVisible);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = endpointStroke.withValues(alpha: endpointVisible);
      canvas.drawCircle(tip, 6, fill);
      canvas.drawCircle(tip, 6, stroke);
    }
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.progress != progress ||
      old.ticksProgress != ticksProgress ||
      old.endpointVisible != endpointVisible ||
      old.scoreFraction != scoreFraction;
}
