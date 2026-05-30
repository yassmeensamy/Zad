part of '../celebration_overlay.dart';

// ===========================================================================
// Crescent variant pieces
// ===========================================================================

class _Twinkle {
  const _Twinkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.phase,
    required this.warm,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double phase;
  final bool warm;
}

class _TwinkleView extends StatelessWidget {
  const _TwinkleView({
    required this.animation,
    required this.twinkle,
    required this.warm,
    required this.cool,
  });

  final Animation<double> animation;
  final _Twinkle twinkle;
  final Color warm;
  final Color cool;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final adjusted =
            ((t - twinkle.delay) / (1 - twinkle.delay)).clamp(0.0, 1.0);
        if (adjusted <= 0) return const SizedBox.shrink();

        // Two slow twinkle cycles over the visible window.
        final twinkleWave =
            0.5 + 0.5 * sin(twinkle.phase + adjusted * pi * 3.2);
        final fadeIn = (adjusted / 0.18).clamp(0.0, 1.0);
        final fadeOut = 1 - _interval(t, 0.82, 1.0);
        final opacity = twinkleWave * fadeIn * fadeOut;
        if (opacity < 0.02) return const SizedBox.shrink();

        final dx = cos(twinkle.angle) * twinkle.distance;
        final dy = sin(twinkle.angle) * twinkle.distance;
        final scale = 0.6 + 0.4 * twinkleWave;
        final color = twinkle.warm ? warm : cool;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star_rounded,
              size: twinkle.size,
              color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            ),
          ),
        );
      },
    );
  }
}

class _DottedOrbit extends StatelessWidget {
  const _DottedOrbit({
    required this.animation,
    required this.color,
    required this.radius,
    required this.dotCount,
    required this.dotSize,
    required this.appearStart,
    required this.appearEnd,
    this.reverse = false,
  });

  final Animation<double> animation;
  final Color color;
  final double radius;
  final int dotCount;
  final double dotSize;
  final double appearStart;
  final double appearEnd;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final appear = Curves.easeOutCubic.transform(
          _interval(t, appearStart, appearEnd),
        );
        final fadeOut = 1 - _interval(t, 0.76, 1.0);
        final opacity = appear * fadeOut;
        if (opacity <= 0.001) return const SizedBox.shrink();
        final rotation = (reverse ? -1 : 1) * t * 2 * pi * 0.22;

        return Transform.rotate(
          angle: rotation,
          child: CustomPaint(
            size: Size((radius + dotSize) * 2, (radius + dotSize) * 2),
            painter: _OrbitDotsPainter(
              color: color,
              opacity: opacity,
              radius: radius,
              dotCount: dotCount,
              dotSize: dotSize,
              appear: appear,
            ),
          ),
        );
      },
    );
  }
}

class _OrbitDotsPainter extends CustomPainter {
  _OrbitDotsPainter({
    required this.color,
    required this.opacity,
    required this.radius,
    required this.dotCount,
    required this.dotSize,
    required this.appear,
  });

  final Color color;
  final double opacity;
  final double radius;
  final int dotCount;
  final double dotSize;
  final double appear;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (var i = 0; i < dotCount; i++) {
      final a = (i / dotCount) * 2 * pi;
      final x = cx + cos(a) * radius;
      final y = cy + sin(a) * radius;
      // Every 4th dot is larger — gives rotation a visible cadence.
      final s = (i % 4 == 0 ? dotSize * 1.7 : dotSize * 0.75) * appear;
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitDotsPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.appear != appear ||
      old.radius != radius;
}

class _MoonBadge extends StatelessWidget {
  const _MoonBadge({
    required this.animation,
    required this.isCorrect,
    required this.primary,
    required this.secondary,
    required this.canvas,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color primary;
  final Color secondary;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Moonrise: enter from below, then settle.
        final rise = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.40));
        final pop = Curves.easeOutBack.transform(_interval(t, 0.10, 0.50));
        final fadeIn = _interval(t, 0.0, 0.30);
        final settle = isCorrect
            ? sin(_interval(t, 0.42, 0.92) * pi) * 0.05
            : 0.0;
        final bob = isCorrect
            ? sin(_interval(t, 0.40, 0.95) * pi * 2) * 2
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.30, 0.62);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

        final dyRise = (1 - rise) * 36;
        final scale = 0.65 + 0.35 * pop + settle;

        final child = isCorrect
            ? _CrescentVisual(primary: primary, secondary: secondary)
            : _WrongVisual(primary: primary, canvas: canvas);

        return Opacity(
          opacity: fadeIn.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(shake, dyRise - bob),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

class _CrescentVisual extends StatelessWidget {
  const _CrescentVisual({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.50),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CrescentPainter(primary: primary, secondary: secondary),
      ),
    );
  }
}

class _WrongVisual extends StatelessWidget {
  const _WrongVisual({required this.primary, required this.canvas});

  final Color primary;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.42),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.close_rounded, color: canvas, size: 34),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  _CrescentPainter({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.36;

    // Build the crescent by subtracting an offset inner disk from the outer.
    final outer = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final inner = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(cx + r * 0.42, cy - r * 0.12),
          radius: r * 0.90,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, outer, inner);

    final shader = LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()..shader = shader;
    canvas.drawPath(crescent, paint);

    // Small companion star next to the crescent opening.
    final starCenter = Offset(cx + r * 0.92, cy - r * 0.50);
    final starR = r * 0.22;
    _drawStar(canvas, starCenter, starR, paint, innerRatio: 0.46);
  }

  @override
  bool shouldRepaint(_CrescentPainter old) =>
      old.primary != primary || old.secondary != secondary;
}
