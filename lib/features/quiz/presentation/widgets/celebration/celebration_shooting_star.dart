part of '../celebration_overlay.dart';

// ===========================================================================
// Shooting Star variant pieces
// ===========================================================================

/// Bright circular flash that pops on the star's impact at center.
class _FlashBurst extends StatelessWidget {
  const _FlashBurst({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Flash centered on the moment the star lands (~0.34).
        final progress = _interval(t, 0.26, 0.64);
        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(progress);
        final size = 70 + eased * 210;
        // Bright at start, fades fast.
        final opacity = ((1 - progress) * (1 - progress) * 1.15).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.95 * opacity),
                color.withValues(alpha: 0.45 * opacity),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _ShootingStarBadge extends StatelessWidget {
  const _ShootingStarBadge({
    required this.animation,
    required this.isCorrect,
    required this.primary,
    required this.secondary,
    required this.canvas,
    required this.fromAngle,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color primary;
  final Color secondary;
  final Color canvas;
  final double fromAngle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Flight from off-screen toward the center, decelerating.
        final flight = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.36));
        // Pop on landing.
        final pop = Curves.easeOutBack.transform(_interval(t, 0.30, 0.58));
        final settle = isCorrect
            ? sin(_interval(t, 0.55, 0.95) * pi) * 0.06
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.36, 0.70);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

        // Position: starts ~180px away along fromAngle, lands at 0,0.
        const flightDistance = 180.0;
        final remaining = 1 - flight;
        final dx = cos(fromAngle) * flightDistance * remaining;
        final dy = sin(fromAngle) * flightDistance * remaining;

        final scale = 0.55 + 0.45 * pop + settle;
        final trailOpacity = (1 - flight).clamp(0.0, 1.0);
        final landed = (flight - 0.7) / 0.3;
        final glowOpacity = landed.clamp(0.0, 1.0);

        final child = isCorrect
            ? CustomPaint(
                size: const Size(200, 200),
                painter: _ShootingStarPainter(
                  primary: primary,
                  secondary: secondary,
                  highlight: canvas,
                  fromAngle: fromAngle,
                  trailLength: 140 * (1 - flight * 0.82),
                  trailOpacity: trailOpacity,
                  glowOpacity: glowOpacity,
                ),
              )
            : _WrongVisual(primary: primary, canvas: canvas);

        return Transform.translate(
          offset: Offset(dx + shake, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

class _ShootingStarPainter extends CustomPainter {
  _ShootingStarPainter({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.fromAngle,
    required this.trailLength,
    required this.trailOpacity,
    required this.glowOpacity,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
  final double fromAngle;
  final double trailLength;
  final double trailOpacity;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Trail: a tapered streak pointing back along fromAngle.
    if (trailOpacity > 0.02 && trailLength > 2) {
      final tailEnd = Offset(
        cx + cos(fromAngle) * trailLength,
        cy + sin(fromAngle) * trailLength,
      );
      final trailRect = Rect.fromPoints(tailEnd, center);

      // Outer wide glow stripe.
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            secondary.withValues(alpha: 0.0),
            secondary.withValues(alpha: trailOpacity * 0.55),
            primary.withValues(alpha: trailOpacity * 0.85),
          ],
        ).createShader(trailRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 20;
      canvas.drawLine(tailEnd, center, glowPaint);

      // Bright core stripe.
      final corePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primary.withValues(alpha: 0.0),
            primary.withValues(alpha: trailOpacity),
            highlight.withValues(alpha: trailOpacity),
          ],
        ).createShader(trailRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.5;
      canvas.drawLine(tailEnd, center, corePaint);
    }

    // Soft halo behind the star (grows once landed).
    if (glowOpacity > 0.02) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.70 * glowOpacity),
            primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 60));
      canvas.drawCircle(center, 60, haloPaint);
    }

    // The star itself — gradient gold with a bright inner highlight.
    const outerR = 32.0;
    final starShader = RadialGradient(
      colors: [highlight, primary, secondary],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: outerR));
    _drawStar(canvas, center, outerR, Paint()..shader = starShader,
        innerRatio: 0.42);

    // Small specular highlight near the upper-left of the star.
    final highlightPaint = Paint()
      ..color = highlight.withValues(alpha: 0.9);
    canvas.drawCircle(
      Offset(cx - outerR * 0.22, cy - outerR * 0.30),
      outerR * 0.20,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.fromAngle != fromAngle ||
      old.trailLength != trailLength ||
      old.trailOpacity != trailOpacity ||
      old.glowOpacity != glowOpacity;
}

/// A single centered radial flare that pops at the moment the star lands.
/// Uses a positioned-absolute layout so it is rigidly anchored to the
/// exact center of the overlay, never offset by sibling layout flow.
class _ImpactSparks extends StatelessWidget {
  const _ImpactSparks({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              final progress = _interval(t, 0.30, 0.66);
              if (progress <= 0 || progress >= 1) {
                return const SizedBox.shrink();
              }
              final eased = Curves.easeOutCubic.transform(progress);
              final fade = (1 - progress).clamp(0.0, 1.0);
              final size = 38 + eased * 32; // 38 → 70 px, tight
              return Opacity(
                opacity: fade,
                child: Icon(
                  Icons.flare_rounded,
                  size: size,
                  color: color,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
