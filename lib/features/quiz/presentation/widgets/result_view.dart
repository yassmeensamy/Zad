import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Quiz result screen — adapted from "Zad Quiz Result v2" design.
///
/// A half-circle gauge tells the story. The amber-gradient progress arc
/// sweeps from left over 1.6s while a count-up percentage runs in sync
/// underneath, 21 tick marks fade in along the inside of the arc with a
/// staggered delay, and an endpoint dot drops in at the progress tip.
/// Below the gauge: an italic title, an Arabic line, a clean three-stat
/// strip with hairline dividers, and a deep-olive CTA with a slow looping
/// amber shimmer.
class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    required this.points,
    required this.questionsCompleted,
    required this.totalRetries,
    required this.motivationalKey,
    required this.onDone,
    this.firstTryCorrect,
    this.elapsed,
  });

  final int points;
  final int questionsCompleted;
  final int totalRetries;
  final String? motivationalKey;
  final VoidCallback onDone;

  /// Number of questions answered correctly on the first try (round 1).
  /// If null, falls back to `questionsCompleted - totalRetries`.
  final int? firstTryCorrect;

  /// Total time from quiz start to finish. If null, the time stat is hidden.
  final Duration? elapsed;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _shimmer;

  // Stages — windows are normalized [0,1] over the 2750ms master timeline.
  late final Animation<double> _arc;       // 0.18 → 0.76 (arc draw)
  late final Animation<double> _ticks;     // 0.21 → 0.55 (tick fade-in)
  late final Animation<double> _endpoint;  // 0.74 → 0.84
  late final Animation<double> _eyebrow;   // 0.07 → 0.25
  late final Animation<double> _count;     // 0.18 → 0.76 (sync with arc)
  late final Animation<double> _percent;   // 0.69 → 0.85 (% sup fade)
  late final Animation<double> _meta;      // 0.36 → 0.55
  late final Animation<double> _title;     // 0.58 → 0.80
  late final Animation<double> _arabic;    // 0.64 → 0.86
  late final Animation<double> _stats;     // 0.71 → 0.93
  late final Animation<double> _cta;       // 0.78 → 1.00

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2750),
    );
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    Animation<double> stage(double s, double e, [Curve c = Curves.easeOutCubic]) =>
        CurvedAnimation(parent: _entrance, curve: Interval(s, e, curve: c));

    _eyebrow = stage(0.07, 0.25);
    _arc = stage(0.18, 0.76, Curves.easeOutCubic);
    _ticks = stage(0.21, 0.55);
    _count = stage(0.18, 0.76, Curves.easeOutCubic);
    _meta = stage(0.36, 0.55);
    _title = stage(0.58, 0.80);
    _arabic = stage(0.64, 0.86);
    _percent = stage(0.69, 0.85);
    _endpoint = stage(0.74, 0.84);
    _stats = stage(0.71, 0.93);
    _cta = stage(0.78, 1.00);

    _entrance.forward();
    _entrance.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        _shimmer.repeat();
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  // ─── Score derivation from available state ────────────────────────

  int get _firstTryCorrect {
    if (widget.firstTryCorrect != null) {
      return widget.firstTryCorrect!.clamp(0, widget.questionsCompleted);
    }
    final c = widget.questionsCompleted - widget.totalRetries;
    return c.clamp(0, widget.questionsCompleted);
  }

  String _formatElapsed(Duration d) {
    final total = d.inSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  int get _scorePercent {
    if (widget.questionsCompleted <= 0) return 0;
    return ((_firstTryCorrect / widget.questionsCompleted) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final paper = Color.lerp(colors.canvas, colors.canvasRaised, 0.25)!;

    return SafeArea(
      child: Container(
        // Soft warm vignette layered over the canvas.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.1,
            colors: [
              colors.accent.withValues(alpha: 0.10),
              paper.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.55],
          ),
        ),
        child: Stack(
          children: [
            // Bottom warm vignette
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 1),
                      radius: 1.0,
                      colors: [
                        colors.dateSoft.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.50],
                    ),
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 28, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(flex: 2, child: SizedBox.shrink()),
                          _buildHero(colors),
                          const SizedBox(height: 14),
                          _buildMeta(colors),
                          const SizedBox(height: 32),
                          _buildTitle(colors),
                          const SizedBox(height: 36),
                          _buildStats(colors),
                          const Expanded(flex: 3, child: SizedBox.shrink()),
                          _buildCta(colors),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero gauge ──────────────────────────────────────────────────

  Widget _buildHero(AppColorsTheme colors) {
    // Container is 2:1.4 — half-circle fits naturally with its diameter at
    // the bottom and the apex at the top. Center stack overlays the arc.
    return Center(
      child: SizedBox(
        width: 320,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_arc, _ticks, _endpoint]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GaugePainter(
                      progress: _arc.value * (_scorePercent / 100),
                      ticksProgress: _ticks.value,
                      endpointVisible: _endpoint.value,
                      scoreFraction: _scorePercent / 100,
                      trackColor: colors.oliveDeep.withValues(alpha: 0.08),
                      gradientStart: colors.accentDeep,
                      gradientMid: colors.accent,
                      gradientEnd:
                          Color.lerp(colors.accent, colors.canvas, 0.30)!,
                      tickColor: colors.oliveDeep.withValues(alpha: 0.18),
                      endpointFill: colors.canvas,
                      endpointStroke: colors.accentDeep,
                      glowColor: colors.accent,
                    ),
                  );
                },
              ),
            ),
            // Center stack: nestled inside the arc, biased slightly upward
            // so the eyebrow + number sit under the apex with breathing room.
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 18),
              child: _buildCenterStack(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterStack(AppColorsTheme colors) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final scoreLabel = isArabic ? 'النتيجة' : 'SCORE';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Reveal(
          animation: _eyebrow,
          offsetY: 8,
          child: Text(
            scoreLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 4.0,
              height: 1.1,
              color: colors.accentDeep,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Big count-up number + % as a baseline-aligned superscript.
        // Force LTR so the % always sits to the right of the digits, even
        // when the page is in Arabic.
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AnimatedBuilder(
            animation: Listenable.merge([_count, _percent]),
            builder: (context, _) {
              final shown = (_scorePercent * _count.value).round();
              return Opacity(
                opacity: _count.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - _count.value.clamp(0.0, 1.0)) * 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$shown',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                          letterSpacing: -3.0,
                          color: colors.oliveDeep,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Opacity(
                        opacity: _percent.value.clamp(0.0, 1.0),
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            height: 1.0,
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Meta line (sits BELOW the curve) ────────────────────────────

  Widget _buildMeta(AppColorsTheme colors) {
    return _Reveal(
      animation: _meta,
      offsetY: 8,
      child: Text(
        'quiz.result.questions_completed'.tr(args: ['$_firstTryCorrect']),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: colors.oliveSoft,
          letterSpacing: 0.2,
          height: 1.4,
        ),
      ),
    );
  }

  // ─── Italic title + Arabic line ─────────────────────────────────

  Widget _buildTitle(AppColorsTheme colors) {
    final motivation = (widget.motivationalKey ?? 'quiz.result.closing').tr();
    return Column(
      children: [
        _Reveal(
          animation: _title,
          offsetY: 10,
          child: Text(
            motivation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.15,
              letterSpacing: -0.4,
              color: colors.oliveDeep,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Reveal(
          animation: _arabic,
          offsetY: 8,
          child: Text(
            'ما شاء الله',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              color: colors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Three-stat strip ────────────────────────────────────────────

  Widget _buildStats(AppColorsTheme colors) {
    final numStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: colors.oliveDeep,
      height: 1.0,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return _Reveal(
      animation: _stats,
      offsetY: 12,
      child: Row(
        children: [
          // Correct: firstTryCorrect / total
          Expanded(
            child: _StatCell(
              valueChild: RichText(
                text: TextSpan(
                  style: numStyle,
                  children: [
                    TextSpan(text: '$_firstTryCorrect'),
                    TextSpan(
                      text: '/${widget.questionsCompleted}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.oliveSoft,
                      ),
                    ),
                  ],
                ),
              ),
              label: 'quiz.result.stat_correct',
              fallback: 'CORRECT',
              colors: colors,
            ),
          ),
          _Divider(colors: colors),
          // Time: mm:ss elapsed (hidden if no elapsed data)
          Expanded(
            child: _StatCell(
              valueChild: Text(
                widget.elapsed != null ? _formatElapsed(widget.elapsed!) : '—',
                style: numStyle,
              ),
              label: 'quiz.result.stat_time',
              fallback: 'TIME',
              colors: colors,
            ),
          ),
          _Divider(colors: colors),
          // XP earned: +points
          Expanded(
            child: _StatCell(
              valueChild: Text(
                '+${widget.points}',
                style: numStyle,
              ),
              label: 'quiz.result.stat_xp_earned',
              fallback: 'XP EARNED',
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Olive CTA with looping shimmer ──────────────────────────────

  Widget _buildCta(AppColorsTheme colors) {
    return _Reveal(
      animation: _cta,
      offsetY: 14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onDone,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          splashColor: colors.accent.withValues(alpha: 0.15),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              color: colors.oliveDeep,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: colors.oliveDeep.withValues(alpha: 0.30),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Stack(
                children: [
                  // Looping amber shimmer sweep
                  AnimatedBuilder(
                    animation: _shimmer,
                    builder: (context, _) {
                      return Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final t = _shimmer.value;
                            // dwell on left then sweep across
                            final pos = t < 0.6 ? (t / 0.6) : 1.0;
                            return Stack(
                              children: [
                                Positioned(
                                  left: -160 + pos * (c.maxWidth + 320),
                                  top: 0,
                                  bottom: 0,
                                  width: 160,
                                  child: Transform.rotate(
                                    angle: -math.pi / 9,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            colors.accent.withValues(alpha: 0),
                                            colors.accent.withValues(alpha: 0.18),
                                            colors.accent.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // CTA label + arrow
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'quiz.result.done'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.85,
                            color: colors.canvas,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: colors.canvas,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Painter: half-circle gauge with track, gradient progress, ticks, endpoint

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
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
    // Geometry is size-relative so the painter scales with its container.
    // Arc baseline (the chord) anchors near the bottom of the box; the
    // apex curves toward the top. Radius leaves a safe margin for the
    // gradient stroke + glow halo.
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

    // Progress (gradient stroke)
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

      // Progress arc proper
      final prog = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, math.pi, sweep, false, prog);
    }

    // Tick marks (21, on the inside of the arc)
    if (ticksProgress > 0) {
      for (var i = 0; i < _tickCount; i++) {
        // Stagger: each tick reaches full opacity 0.04 of the timeline after
        // the previous, normalized into [0, 1] for ticksProgress.
        final t = i / (_tickCount - 1);
        final tickStart = (i * 0.04).clamp(0.0, 1.0);
        final localT =
            ((ticksProgress - tickStart) / (1 - tickStart)).clamp(0.0, 1.0);
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

    // Endpoint dot at progress tip
    if (endpointVisible > 0) {
      final tipAngle = math.pi - scoreFraction * math.pi;
      final tip = Offset(
        cx + math.cos(tipAngle) * r,
        cy - math.sin(tipAngle) * r,
      );
      final fill = Paint()..color = endpointFill.withValues(alpha: endpointVisible);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = endpointStroke.withValues(alpha: endpointVisible);
      canvas.drawCircle(tip, 6, fill);
      canvas.drawCircle(tip, 6, stroke);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress ||
      old.ticksProgress != ticksProgress ||
      old.endpointVisible != endpointVisible ||
      old.scoreFraction != scoreFraction;
}

// ─── Helpers ─────────────────────────────────────────────────────

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.child,
    this.offsetY = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offsetY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: colors.oliveDeep.withValues(alpha: 0.10),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.valueChild,
    required this.label,
    required this.fallback,
    required this.colors,
  });

  final Widget valueChild;
  final String label;
  final String fallback;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    final translated = label.tr();
    final resolved = translated == label ? fallback : translated.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          valueChild,
          const SizedBox(height: 8),
          Text(
            resolved,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              height: 1.2,
              color: colors.oliveSoft,
            ),
          ),
        ],
      ),
    );
  }
}
