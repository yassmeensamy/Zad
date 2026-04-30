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

/// Tiled eight-point star tessellation rendered as a faint backdrop
/// behind the mihrab hero. Drawn with very low opacity so it reads
/// as paper texture rather than chrome.
class StarTessellationPainter extends CustomPainter {
  const StarTessellationPainter({
    required this.color,
    this.tile = 44.0,
    this.opacity = 0.06,
  });

  final Color color;
  final double tile;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = color.withValues(alpha: opacity);

    final cols = (size.width / tile).ceil() + 2;
    final rows = (size.height / tile).ceil() + 2;
    final r = tile * 0.42;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final cx = col * tile + (row.isEven ? 0 : tile / 2);
        final cy = row * tile;
        canvas.drawPath(_smallStar(Offset(cx, cy), r), paint);
      }
    }
  }

  Path _smallStar(Offset c, double r) {
    final path = Path();
    const n = 16;
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? r : r * 0.55;
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
  bool shouldRepaint(StarTessellationPainter old) =>
      old.color != color || old.tile != tile || old.opacity != opacity;
}

/// Mihrab arch — the silhouette of a prayer niche. Used to frame the
/// avatar so the hero feels architectural rather than card-shaped.
class MihrabArchClipper extends CustomClipper<Path> {
  const MihrabArchClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final shoulder = h * 0.55;
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, shoulder)
      // Left shoulder curving inward
      ..quadraticBezierTo(0, shoulder * 0.45, w * 0.18, shoulder * 0.40)
      // Sweep up to the apex (pointed arch)
      ..quadraticBezierTo(w * 0.5, -h * 0.05, w * 0.82, shoulder * 0.40)
      // Right shoulder
      ..quadraticBezierTo(w, shoulder * 0.45, w, shoulder)
      ..lineTo(w, h)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Eight-point star tessellation faded into the top-end corner — the same
/// pattern used in the profile hero, masked with a radial fade so it
/// dissolves into the surface. Drop into a [Stack] to decorate any
/// container. Direction-aware: in RTL it fades from the top-left.
class IslamicPatternCorner extends StatelessWidget {
  const IslamicPatternCorner({
    super.key,
    required this.color,
    this.size = 110,
    this.tile = 24,
    this.opacity = 0.18,
  });

  final Color color;
  final double size;
  final double tile;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return PositionedDirectional(
      top: 0,
      end: 0,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => RadialGradient(
              center: Alignment(isRtl ? -1 : 1, -1),
              radius: 0.7,
              stops: const [0.0, 0.55, 1.0],
              colors: [
                Colors.black.withValues(alpha: opacity),
                Colors.black.withValues(alpha: opacity * 0.4),
                Colors.black.withValues(alpha: 0),
              ],
            ).createShader(rect),
            child: CustomPaint(
              painter: StarTessellationPainter(
                color: color,
                tile: tile,
                opacity: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative Islamic border band — top and bottom hairlines with
/// a centred motif of alternating eight-point stars and diamonds.
/// Used as a horizontal divider beneath the hero.
class IslamicBandPainter extends CustomPainter {
  const IslamicBandPainter({required this.color, this.spacing = 26.0});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = color.withValues(alpha: 0.45);

    final motifStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.85);

    final motifFill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.15);

    final cy = size.height / 2;
    final r = size.height * 0.36;

    // Top + bottom hairlines bracket the band.
    canvas.drawLine(Offset(0, 0.5), Offset(size.width, 0.5), hairline);
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      hairline,
    );

    // Centred connector line.
    canvas.drawLine(
      Offset(0, cy),
      Offset(size.width, cy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = color.withValues(alpha: 0.25),
    );

    // Repeating motif: star, diamond, star, diamond …
    final count = (size.width / spacing).floor();
    final start = (size.width - (count - 1) * spacing) / 2;
    for (var i = 0; i < count; i++) {
      final cx = start + i * spacing;
      if (i.isEven) {
        _paintStar(canvas, Offset(cx, cy), r, motifFill, motifStroke);
      } else {
        _paintDiamond(canvas, Offset(cx, cy), r * 0.55, motifFill, motifStroke);
      }
    }
  }

  void _paintStar(Canvas c, Offset center, double r, Paint fill, Paint stroke) {
    final path = Path();
    const n = 16;
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? r : r * 0.6;
      final p = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    c.drawPath(path, fill);
    c.drawPath(path, stroke);
  }

  void _paintDiamond(Canvas c, Offset cn, double r, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(cn.dx, cn.dy - r)
      ..lineTo(cn.dx + r, cn.dy)
      ..lineTo(cn.dx, cn.dy + r)
      ..lineTo(cn.dx - r, cn.dy)
      ..close();
    c.drawPath(path, fill);
    c.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(IslamicBandPainter old) =>
      old.color != color || old.spacing != spacing;
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
