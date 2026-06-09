part of 'celebration.dart';

// ─── Trophy ──────────────────────────────────────────────────────────────────

class _Trophy extends StatefulWidget {
  const _Trophy({required this.palette});

  final _CelPalette palette;

  @override
  State<_Trophy> createState() => _TrophyState();
}

class _TrophyState extends State<_Trophy> with TickerProviderStateMixin {
  // Drives the dashed ring's slow rotation.
  late final AnimationController _spin;
  // Drives the checkmark draw + the shine sweep.
  late final AnimationController _detail;
  late final Animation<double> _check;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _detail = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _check = CurvedAnimation(
      parent: _detail,
      curve: const Interval(0.40, 0.58, curve: Curves.easeOut),
    );
    _shine = CurvedAnimation(
      parent: _detail,
      curve: const Interval(0.54, 0.96, curve: Curves.easeInOut),
    );
    _detail.forward();
  }

  @override
  void dispose() {
    _spin.dispose();
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed ring.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => Transform.rotate(
                angle: _spin.value * 2 * math.pi,
                child: CustomPaint(painter: _DashedRingPainter(p)),
              ),
            ),
          ),
          // Gold disc + checkmark + shine sweep.
          SizedBox(
            width: 132,
            height: 132,
            child: AnimatedBuilder(
              animation: _detail,
              builder: (context, _) => CustomPaint(
                painter: _DiscPainter(
                  palette: p,
                  checkProgress: _check.value,
                  shineProgress: _shine.value,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .scaleXY(
          begin: 0,
          end: 1,
          delay: 350.ms,
          duration: 900.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(delay: 350.ms, duration: 300.ms)
        .rotate(
          begin: -0.08,
          end: 0,
          delay: 350.ms,
          duration: 900.ms,
          curve: Curves.elasticOut,
        );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter(this.palette);

  final _CelPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.accent.withValues(alpha: 0.45);

    const dash = 3.0;
    const gap = 7.0;
    final circumference = 2 * math.pi * r;
    final steps = (circumference / (dash + gap)).floor();
    final sweep = dash / r;
    for (var i = 0; i < steps; i++) {
      final start = (i * (dash + gap) / r);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) => false;
}

class _DiscPainter extends CustomPainter {
  _DiscPainter({
    required this.palette,
    required this.checkProgress,
    required this.shineProgress,
  });

  final _CelPalette palette;
  final double checkProgress;
  final double shineProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Drop glow.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = palette.glow.withValues(alpha: 0.5 * palette.glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Gilded face: highlight near top-left, deepening to amber-deep at the rim.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.48),
          radius: 1.05,
          colors: [
            palette.creamHi,
            palette.accentSoft,
            palette.accent,
            palette.accentDeep,
          ],
          stops: const [0.0, 0.38, 0.62, 1.0],
        ).createShader(rect),
    );

    // Rim light.
    canvas.drawCircle(
      c,
      r - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = palette.accentSoft.withValues(alpha: 0.6),
    );

    // Specular highlight.
    final specRect = Rect.fromCenter(
      center: c + Offset(-r * 0.18, -r * 0.34),
      width: r * 0.72,
      height: r * 0.5,
    );
    canvas.drawOval(
      specRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(specRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Checkmark — drawn progressively.
    if (checkProgress > 0) {
      final p0 = c + Offset(-r * 0.34, r * 0.02);
      final p1 = c + Offset(-r * 0.08, r * 0.28);
      final p2 = c + Offset(r * 0.36, -r * 0.26);
      final full = Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
      final drawn = _trimPath(full, checkProgress);
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = palette.ctaInk,
      );
    }

    // Shine sweep across the face.
    if (shineProgress > 0 && shineProgress < 1) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      final x = -size.width * 0.6 + shineProgress * size.width * 1.9;
      final band = Rect.fromLTWH(
        x,
        -size.height * 0.5,
        size.width * 0.42,
        size.height * 2,
      );
      canvas.translate(c.dx, c.dy);
      canvas.rotate(0.32);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(band),
      );
      canvas.restore();
    }
  }

  Path _trimPath(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (a, m) => a + m.length);
    var remaining = total * t.clamp(0.0, 1.0);
    final out = Path();
    for (final m in metrics) {
      if (remaining <= 0) break;
      final len = math.min(remaining, m.length);
      out.addPath(m.extractPath(0, len), Offset.zero);
      remaining -= len;
    }
    return out;
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) =>
      oldDelegate.checkProgress != checkProgress ||
      oldDelegate.shineProgress != shineProgress;
}

// ─── Rays ────────────────────────────────────────────────────────────────────

class _RaysLayer extends StatefulWidget {
  const _RaysLayer({required this.palette});

  final _CelPalette palette;

  @override
  State<_RaysLayer> createState() => _RaysLayerState();
}

class _RaysLayerState extends State<_RaysLayer> with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _enter]),
      builder: (context, _) {
        final e = Curves.easeOut.transform(_enter.value);
        return Opacity(
          opacity: e * 0.9,
          child: Transform.scale(
            scale: 0.2 + 0.8 * e,
            child: Transform.rotate(
              angle: _spin.value * 2 * math.pi,
              child: SizedBox(
                width: 440,
                height: 440,
                child: CustomPaint(painter: _RaysPainter(widget.palette)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.palette);

  final _CelPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);

    // Build 60 thin gold spikes as a sweep gradient.
    final spike = palette.accentSoft.withValues(alpha: 0.22);
    final clear = palette.accentSoft.withValues(alpha: 0);
    final colors = <Color>[];
    final stops = <double>[];
    const n = 60;
    for (var i = 0; i < n; i++) {
      final base = i / n;
      stops.add(base);
      colors.add(clear);
      stops.add(base + 0.5 / n);
      colors.add(spike);
      stops.add(base + 0.98 / n);
      colors.add(clear);
    }

    canvas.saveLayer(rect, Paint());
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()
        ..shader =
            SweepGradient(colors: colors, stops: stops).createShader(rect),
    );
    // Radial mask: solid core fading out toward the rim (closest-side feel).
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = RadialGradient(
          colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
          stops: const [0.0, 0.30, 0.72],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => false;
}

// ─── Glow pool ───────────────────────────────────────────────────────────────

class _PoolLayer extends StatefulWidget {
  const _PoolLayer({required this.palette});

  final _CelPalette palette;

  @override
  State<_PoolLayer> createState() => _PoolLayerState();
}

class _PoolLayerState extends State<_PoolLayer> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _pulse]),
      builder: (context, _) {
        final e = Curves.easeOut.transform(_enter.value);
        final pulse = 1 + 0.08 * Curves.easeInOut.transform(_pulse.value);
        return Opacity(
          opacity: e,
          child: Transform.scale(
            scale: (0.4 + 0.6 * e) * pulse,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    p.accent.withValues(alpha: 0.5 * p.glowOpacity),
                    p.glow.withValues(alpha: 0.18 * p.glowOpacity),
                    p.glow.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.5, 0.72],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Particle engine (confetti + fireworks) ──────────────────────────────────

class _Confetto {
  _Confetto({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.g,
    required this.w,
    required this.h,
    required this.rot,
    required this.vr,
    required this.col,
    required this.decay,
    required this.ribbon,
  });

  double x, y, vx, vy, rot, life = 1;
  final double g, w, h, vr, decay;
  final Color col;
  final bool ribbon;
}

class _Rocket {
  _Rocket({
    required this.x,
    required this.y,
    required this.tx,
    required this.ty,
    required this.vy,
    required this.col,
  });

  double x, y, vy;
  final double tx, ty;
  final Color col;
  bool done = false;
}

class _Spark {
  _Spark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.g,
    required this.col,
    required this.decay,
    required this.size,
  });

  double x, y, vx, vy, life = 1;
  final double g, decay, size;
  final Color col;
}

/// Holds and advances the confetti / fireworks particles. Stepped from the
/// stage's [Ticker] in fixed 1/60 substeps so the tuned per-frame constants
/// behave the same regardless of the device refresh rate.
class _Fx {
  _Fx(this.palette);

  final _CelPalette palette;
  final List<_Confetto> confetti = [];
  final List<_Rocket> rockets = [];
  final List<_Spark> sparks = [];
  final math.Random _rng = math.Random();

  double _acc = 0;
  static const double _stepDt = 1 / 60;

  double _rnd(double a, double b) => a + _rng.nextDouble() * (b - a);
  Color _pick(List<Color> arr) => arr[_rng.nextInt(arr.length)];

  void burstConfetti(Size size) {
    final w = size.width;
    final cx = w / 2;
    final cy = size.height * 0.40;
    for (var i = 0; i < 60; i++) {
      final ang = _rnd(0, math.pi * 2);
      final sp = _rnd(3, 9);
      confetti.add(_Confetto(
        x: cx,
        y: cy,
        vx: math.cos(ang) * sp,
        vy: math.sin(ang) * sp - _rnd(2, 5),
        g: 0.22,
        w: _rnd(5, 10),
        h: _rnd(7, 13),
        rot: _rnd(0, 6.28),
        vr: _rnd(-0.3, 0.3),
        col: _pick(palette.confetti),
        decay: _rnd(0.006, 0.013),
        ribbon: _rng.nextDouble() >= 0.3,
      ));
    }
    for (var i = 0; i < 22; i++) {
      confetti.add(_Confetto(
        x: _rnd(0, w),
        y: _rnd(-60, -10),
        vx: _rnd(-1, 1),
        vy: _rnd(2, 4),
        g: 0.1,
        w: _rnd(4, 8),
        h: _rnd(6, 11),
        rot: _rnd(0, 6.28),
        vr: _rnd(-0.25, 0.25),
        col: _pick(palette.confetti),
        decay: _rnd(0.004, 0.008),
        ribbon: false,
      ));
    }
  }

  void launchRocket(Size size) {
    final w = size.width;
    final h = size.height;
    rockets.add(_Rocket(
      x: _rnd(w * 0.2, w * 0.8),
      y: h * 0.92,
      tx: _rnd(w * 0.2, w * 0.8),
      ty: _rnd(h * 0.16, h * 0.42),
      vy: -_rnd(7, 10),
      col: _pick(palette.fireworks),
    ));
  }

  void _explode(double x, double y, Color col) {
    const n = 46;
    for (var i = 0; i < n; i++) {
      final ang = (math.pi * 2 * i) / n + _rnd(-0.1, 0.1);
      final sp = _rnd(2.2, 6.2);
      sparks.add(_Spark(
        x: x,
        y: y,
        vx: math.cos(ang) * sp,
        vy: math.sin(ang) * sp,
        g: 0.06,
        col: col,
        decay: _rnd(0.012, 0.024),
        size: _rnd(1.6, 3.2),
      ));
    }
    for (var i = 0; i < 14; i++) {
      sparks.add(_Spark(
        x: x,
        y: y,
        vx: _rnd(-1, 1),
        vy: _rnd(-1, 1),
        g: 0.02,
        col: palette.sparkWhite,
        decay: 0.03,
        size: _rnd(1, 2),
      ));
    }
  }

  /// Advances the simulation. Returns true when anything is alive (so the
  /// stage only repaints while particles exist).
  bool step(double dt, Size size) {
    _acc += dt;
    var stepped = false;
    while (_acc >= _stepDt) {
      _acc -= _stepDt;
      _advance(size);
      stepped = true;
    }
    return stepped &&
        (confetti.isNotEmpty || rockets.isNotEmpty || sparks.isNotEmpty);
  }

  void _advance(Size size) {
    final h = size.height;

    for (final p in confetti) {
      p.vy += p.g;
      p.x += p.vx;
      p.y += p.vy;
      p.vx *= 0.99;
      p.rot += p.vr;
      p.life -= p.decay;
    }
    confetti.removeWhere((p) => p.life <= 0 || p.y > h + 40);

    for (final r in rockets) {
      r.x += (r.tx - r.x) * 0.04;
      r.y += r.vy;
      r.vy += 0.12;
      if (r.vy > -1 || r.y <= r.ty) {
        _explode(r.x, r.y, r.col);
        r.done = true;
      }
    }
    rockets.removeWhere((r) => r.done);

    for (final s in sparks) {
      s.vy += s.g;
      s.x += s.vx;
      s.y += s.vy;
      s.vx *= 0.985;
      s.life -= s.decay;
    }
    sparks.removeWhere((s) => s.life <= 0);
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter(this.fx, {required this.palette, required Listenable repaint})
      : super(repaint: repaint);

  final _Fx fx;
  final _CelPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    // Additive glow reads beautifully on the dark canvas; on the light canvas
    // it would blow out to white, so fall back to normal compositing there.
    final paint = Paint()
      ..blendMode = palette.isDark ? BlendMode.plus : BlendMode.srcOver;
    for (final r in fx.rockets) {
      paint.color = r.col;
      canvas.drawCircle(Offset(r.x, r.y), 2.4, paint);
      paint.color = r.col.withValues(alpha: 0.4);
      canvas.drawCircle(Offset(r.x, r.y + 6), 1.6, paint);
    }
    for (final s in fx.sparks) {
      paint.color = s.col.withValues(alpha: s.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) => false;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.fx, {required Listenable repaint})
      : super(repaint: repaint);

  final _Fx fx;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in fx.confetti) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rot);
      paint.color = p.col.withValues(alpha: p.life.clamp(0.0, 1.0));
      final h = p.ribbon ? p.h * 0.5 : p.h;
      canvas.drawRect(Rect.fromLTWH(-p.w / 2, -h / 2, p.w, h), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
