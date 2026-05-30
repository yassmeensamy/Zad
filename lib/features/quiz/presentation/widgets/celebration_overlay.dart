import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

// Variant implementations and shared particle/painter primitives live in
// part files to keep this entry point readable.
part 'celebration/celebration_bloom.dart';
part 'celebration/celebration_stardust.dart';
part 'celebration/celebration_crescent.dart';
part 'celebration/celebration_shooting_star.dart';

double _interval(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

/// Draws a filled five-pointed star centered at [center]. [innerRatio] controls
/// how deep the valleys cut between points. Shared by the crescent and
/// shooting-star painters.
void _drawStar(
  Canvas canvas,
  Offset center,
  double outerR,
  Paint paint, {
  double innerRatio = 0.45,
}) {
  final path = Path();
  const points = 5;
  final innerR = outerR * innerRatio;
  for (var i = 0; i < points * 2; i++) {
    final angle = -pi / 2 + i * pi / points;
    final r = i.isEven ? outerR : innerR;
    final x = center.dx + cos(angle) * r;
    final y = center.dy + sin(angle) * r;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  canvas.drawPath(path, paint);
}

enum CelebrationStyle { bloom, stardust, crescent, shootingStar, random }

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.trigger,
    required this.isCorrect,
    this.messageKey,
    this.style = CelebrationStyle.random,
  });

  final int trigger;
  final bool isCorrect;
  final String? messageKey;

  /// When [CelebrationStyle.random], one of bloom/stardust is picked
  /// deterministically from [trigger] so the same question always shows
  /// the same variant.
  final CelebrationStyle style;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  static const List<String> _correctTitleKeys = [
    'quiz.feedback.correct_title_1',
    'quiz.feedback.correct_title_2',
    'quiz.feedback.correct_title_3',
    'quiz.feedback.correct_title_4',
  ];

  static const List<String> _wrongTitleKeys = [
    'quiz.feedback.wrong_title_1',
    'quiz.feedback.wrong_title_2',
    'quiz.feedback.wrong_title_3',
    'quiz.feedback.wrong_title_4',
  ];

  late AnimationController _ctrl;
  late CelebrationStyle _effectiveStyle;

  late List<_Particle> _particles;
  late List<_Sparkle> _sparkles;
  late List<_Confetti> _confetti;
  late List<_Twinkle> _twinkles;
  late double _ornamentSpin;
  late String _titleKey;

  @override
  void initState() {
    super.initState();
    _seed();
    _ctrl = AnimationController(
      vsync: this,
      duration: _durationFor(_effectiveStyle),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger ||
        oldWidget.isCorrect != widget.isCorrect ||
        oldWidget.style != widget.style) {
      _seed();
      _ctrl.duration = _durationFor(_effectiveStyle);
      _ctrl
        ..reset()
        ..forward();
    }
  }

  Duration _durationFor(CelebrationStyle style) => Duration(
        milliseconds: switch (style) {
          CelebrationStyle.stardust => 2800,
          CelebrationStyle.crescent => 2600,
          CelebrationStyle.shootingStar => 2900,
          _ => 2200,
        },
      );

  void _seed() {
    final rng = Random(widget.trigger ^ (widget.isCorrect ? 0x9E3779B9 : 0));
    final titles = widget.isCorrect ? _correctTitleKeys : _wrongTitleKeys;
    _titleKey = titles[rng.nextInt(titles.length)];

    _effectiveStyle = widget.style == CelebrationStyle.random
        ? const [
            CelebrationStyle.bloom,
            CelebrationStyle.stardust,
            CelebrationStyle.crescent,
            CelebrationStyle.shootingStar,
          ][rng.nextInt(4)]
        : widget.style;

    _ornamentSpin = (rng.nextDouble() - 0.5) * 0.6;

    // Bloom-only particles.
    if (_effectiveStyle == CelebrationStyle.bloom && widget.isCorrect) {
      _particles = List<_Particle>.generate(8, (i) {
        final angleStep = (2 * pi) / 8;
        return _Particle(
          angle: angleStep * i + (rng.nextDouble() - 0.5) * 0.4,
          distance: 60 + rng.nextDouble() * 42,
          size: 7 + rng.nextDouble() * 6,
          delay: 0.10 + rng.nextDouble() * 0.18,
          rotation: (rng.nextDouble() - 0.5) * 1.6,
          isCrescent: rng.nextDouble() < 0.30,
        );
      });
    } else {
      _particles = const [];
    }

    // Stardust sparkles + confetti — only when correct.
    if (_effectiveStyle == CelebrationStyle.stardust && widget.isCorrect) {
      _sparkles = List<_Sparkle>.generate(14, (i) {
        final ringIndex = i % 2;
        final base = ringIndex == 0 ? 70.0 : 105.0;
        final angle = (i / 14) * 2 * pi + (rng.nextDouble() - 0.5) * 0.35;
        return _Sparkle(
          angle: angle,
          distance: base + rng.nextDouble() * 28,
          size: 6 + rng.nextDouble() * 7,
          delay: 0.08 + rng.nextDouble() * 0.22,
          rotation: (rng.nextDouble() - 0.5) * 2.2,
          kind: _SparkleKind.values[rng.nextInt(_SparkleKind.values.length)],
          warm: rng.nextDouble() < 0.55,
        );
      });
      _confetti = List<_Confetti>.generate(10, (i) {
        return _Confetti(
          startAngle: rng.nextDouble() * 2 * pi,
          startRadius: 30 + rng.nextDouble() * 50,
          fall: 110 + rng.nextDouble() * 60,
          sway: 10 + rng.nextDouble() * 14,
          rotation: (rng.nextDouble() - 0.5) * 6,
          size: 4 + rng.nextDouble() * 3.5,
          delay: 0.18 + rng.nextDouble() * 0.22,
          tone: rng.nextInt(3),
        );
      });
    } else {
      _sparkles = const [];
      _confetti = const [];
    }

    // Crescent twinkling-star backdrop — only when correct.
    final needsTwinkles = widget.isCorrect &&
        (_effectiveStyle == CelebrationStyle.crescent ||
            _effectiveStyle == CelebrationStyle.shootingStar);
    if (needsTwinkles) {
      _twinkles = List<_Twinkle>.generate(9, (i) {
        final angle = (i / 9) * 2 * pi + (rng.nextDouble() - 0.5) * 0.5;
        return _Twinkle(
          angle: angle,
          distance: 72 + rng.nextDouble() * 56,
          size: 4 + rng.nextDouble() * 5,
          delay: 0.18 + rng.nextDouble() * 0.28,
          phase: rng.nextDouble() * 2 * pi,
          warm: rng.nextDouble() < 0.6,
        );
      });
    } else {
      _twinkles = const [];
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = Theme.of(context).colorScheme.error;
    final accent = widget.isCorrect ? colors.olive : errorColor;
    final accentSoft = widget.isCorrect ? colors.oliveLeaf : errorColor;

    return IgnorePointer(
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.88, 1.0, curve: Curves.linear),
          ).drive(Tween<double>(begin: 1.0, end: 0.0)),
          child: switch (_effectiveStyle) {
            CelebrationStyle.stardust =>
              _buildStardust(colors, accent, accentSoft),
            CelebrationStyle.crescent =>
              _buildCrescent(colors, accent, accentSoft),
            CelebrationStyle.shootingStar =>
              _buildShootingStar(colors, accent, accentSoft),
            _ => _buildBloom(colors, accent, accentSoft),
          },
        ),
      ),
    );
  }

  // ----- Bloom (original) -------------------------------------------------

  Widget _buildBloom(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _Backdrop(animation: _ctrl, accent: accent),
        for (var i = 0; i < 3; i++)
          _Ring(
            animation: _ctrl,
            ringIndex: i,
            accent: i.isOdd ? accentSoft : accent,
          ),
        for (final p in _particles)
          _ParticleView(
            animation: _ctrl,
            particle: p,
            color: p.isCrescent ? colors.accent : colors.olive,
          ),
        _IconBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          accent: accent,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 138),
          child: _MessageBlock(
            animation: _ctrl,
            title: _titleKey,
            subtitle: widget.messageKey,
            accent: accent,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
          ),
        ),
      ],
    );
  }

  // ----- Stardust (new creative) ------------------------------------------

  Widget _buildStardust(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent; // amber
    final warmSoft = colors.accentSoft; // amber soft

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: accent,
          outer: widget.isCorrect ? warmAccent : accentSoft,
        ),
        if (widget.isCorrect)
          _GeometricOrnament(
            animation: _ctrl,
            accent: accent,
            spinBias: _ornamentSpin,
          ),
        if (widget.isCorrect)
          _LightRays(animation: _ctrl, accent: warmAccent),
        for (var i = 0; i < 2; i++)
          _PulseRing(
            animation: _ctrl,
            startDelay: 0.04 + i * 0.10,
            accent: i.isOdd ? accentSoft : accent,
          ),
        for (final s in _sparkles)
          _SparkleView(
            animation: _ctrl,
            sparkle: s,
            warm: warmAccent,
            cool: accent,
            warmSoft: warmSoft,
          ),
        for (final c in _confetti)
          _ConfettiView(
            animation: _ctrl,
            confetti: c,
            tones: [accent, warmAccent, accentSoft],
          ),
        _HeroBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          accent: accent,
          accentSoft: accentSoft,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 140),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey,
            subtitle: widget.messageKey,
            accent: accent,
            warm: warmAccent,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
            isCorrect: widget.isCorrect,
          ),
        ),
      ],
    );
  }

  // ----- Crescent (moon + star, no checkmark) -----------------------------

  Widget _buildCrescent(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent; // amber
    final warmDeep = colors.accentDeep;
    final warmSoft = colors.accentSoft;

    // For correct, lead with warm amber (the "moon" is gold). Olive
    // becomes the supporting accent. For wrong, fall back to the
    // error-tinted accent passed in.
    final primary = widget.isCorrect ? warmAccent : accent;
    final secondary = widget.isCorrect ? warmDeep : accentSoft;

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: primary,
          outer: widget.isCorrect ? accent : accentSoft,
        ),
        if (widget.isCorrect) ...[
          _DottedOrbit(
            animation: _ctrl,
            color: accent,
            radius: 78,
            dotCount: 18,
            dotSize: 2.4,
            appearStart: 0.06,
            appearEnd: 0.36,
          ),
          _DottedOrbit(
            animation: _ctrl,
            color: warmSoft,
            radius: 110,
            dotCount: 26,
            dotSize: 1.8,
            appearStart: 0.14,
            appearEnd: 0.44,
            reverse: true,
          ),
        ],
        for (var i = 0; i < 2; i++)
          _PulseRing(
            animation: _ctrl,
            startDelay: 0.05 + i * 0.11,
            accent: i.isOdd ? primary : accent,
          ),
        for (final tw in _twinkles)
          _TwinkleView(
            animation: _ctrl,
            twinkle: tw,
            warm: warmAccent,
            cool: accent,
          ),
        _MoonBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          primary: primary,
          secondary: secondary,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 142),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey,
            subtitle: widget.messageKey,
            accent: accent,
            warm: primary,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
            isCorrect: widget.isCorrect,
          ),
        ),
      ],
    );
  }

  // ----- Shooting Star (diagonal streak + landing flash) ------------------

  Widget _buildShootingStar(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent;
    final warmDeep = colors.accentDeep;

    final primary = widget.isCorrect ? warmAccent : accent;
    final secondary = widget.isCorrect ? warmDeep : accentSoft;

    // Deterministic streak direction — pulled from the trigger seed so the
    // same question always comes in from the same diagonal.
    final fromAngle = -pi * 3 / 4 + _ornamentSpin * 0.6; // upper-left-ish

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: primary,
          outer: widget.isCorrect ? warmAccent : accentSoft,
        ),
        // Faint background twinkles set the night-sky stage.
        for (final tw in _twinkles)
          _TwinkleView(
            animation: _ctrl,
            twinkle: tw,
            warm: warmAccent,
            cool: accent,
          ),
        // Flash burst on impact.
        if (widget.isCorrect)
          _FlashBurst(animation: _ctrl, color: warmAccent),
        // Two pulse rings rippling outward from the landing point.
        _PulseRing(
          animation: _ctrl,
          startDelay: 0.32,
          accent: primary,
        ),
        _PulseRing(
          animation: _ctrl,
          startDelay: 0.44,
          accent: warmAccent,
        ),
        // Sharp radiating sparks at the moment of impact.
        if (widget.isCorrect)
          _ImpactSparks(animation: _ctrl, color: warmAccent),
        _ShootingStarBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          primary: primary,
          secondary: secondary,
          canvas: colors.canvas,
          fromAngle: fromAngle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 142),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey,
            subtitle: widget.messageKey,
            accent: accent,
            warm: primary,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
            isCorrect: widget.isCorrect,
          ),
        ),
      ],
    );
  }
}
