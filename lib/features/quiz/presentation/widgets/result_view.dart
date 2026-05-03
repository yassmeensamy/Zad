import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'gauge_painter.dart';
import 'result_cta_button.dart';

const _ease = Curves.easeOutCubic;

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
    with SingleTickerProviderStateMixin {
  // The painter and the count-up share three synchronized values, so one
  // controller still earns its keep here. Everything else is delegated to
  // flutter_animate.
  late final AnimationController _gauge;
  late final Animation<double> _arc;
  late final Animation<double> _ticks;
  late final Animation<double> _endpoint;
  late final Animation<double> _count;

  @override
  void initState() {
    super.initState();
    _gauge = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2750),
    );

    Animation<double> stage(double s, double e) => CurvedAnimation(
      parent: _gauge,
      curve: Interval(s, e, curve: _ease),
    );

    _arc = stage(0.18, 0.76);
    _ticks = stage(0.21, 0.55);
    _endpoint = stage(0.74, 0.84);
    _count = stage(0.18, 0.76);

    _gauge.forward();
  }

  @override
  void dispose() {
    _gauge.dispose();
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
        child: LayoutBuilder(
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
                      _buildCta(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Hero gauge ──────────────────────────────────────────────────

  Widget _buildHero(AppColorsTheme colors) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _gauge,
                builder: (context, _) {
                  return CustomPaint(
                    painter: GaugePainter(
                      progress: _arc.value * (_scorePercent / 100),
                      ticksProgress: _ticks.value,
                      endpointVisible: _endpoint.value,
                      scoreFraction: _scorePercent / 100,
                      trackColor: colors.oliveDeep.withValues(alpha: 0.08),
                      gradientStart: colors.accentDeep,
                      gradientMid: colors.accent,
                      gradientEnd: Color.lerp(
                        colors.accent,
                        colors.canvas,
                        0.30,
                      )!,
                      tickColor: colors.oliveDeep.withValues(alpha: 0.18),
                      endpointFill: colors.canvas,
                      endpointStroke: colors.accentDeep,
                      glowColor: colors.accent,
                    ),
                  );
                },
              ),
            ),
            // Anchor the text to the bottom-center of the painter so the
            // big digits sit near the arc's chord (baseline).
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildCenterStack(colors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterStack(AppColorsTheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveText(
              'quiz.result.score',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
                height: 1.1,
                color: colors.accentDeep,
              ),
            )
            .animate()
            .fadeIn(delay: 192.ms, duration: 495.ms, curve: _ease)
            .moveY(begin: 8, end: 0, duration: 495.ms, curve: _ease),
        const SizedBox(height: 12),
        // Big count-up number + % as a baseline-aligned superscript.
        // Force LTR so the % always sits to the right of the digits, even
        // when the page is in Arabic.
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AnimatedBuilder(
            animation: _count,
            builder: (context, _) {
              final t = _count.value.clamp(0.0, 1.0);
              final shown = (_scorePercent * t).round();
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      ResponsiveText(
                        '$shown',
                        style: AppTextStyles.numericLarge.copyWith(
                          color: colors.oliveDeep,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ResponsiveText(
                        '%',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                          color: colors.accent,
                        ),
                      ).animate().fadeIn(delay: 1897.ms, duration: 440.ms),
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

  // ─── Meta line ───────────────────────────────────────────────────

  Widget _buildMeta(AppColorsTheme colors) {
    return ResponsiveText(
          // Pre-translated because ResponsiveText doesn't expose `args`;
          // the internal .tr() is a no-op on the resolved string.
          'quiz.result.questions_completed'.tr(args: ['$_firstTryCorrect']),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 13.5,
            letterSpacing: 0.2,
            color: colors.oliveSoft,
          ),
        )
        .animate()
        .fadeIn(delay: 990.ms, duration: 522.ms, curve: _ease)
        .moveY(begin: 8, end: 0, duration: 522.ms, curve: _ease);
  }

  // ─── Italic title + Arabic line ─────────────────────────────────

  Widget _buildTitle(AppColorsTheme colors) {
    return Column(
      children: [
        ResponsiveText(
              widget.motivationalKey ?? 'quiz.result.closing',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                color: colors.oliveDeep,
              ),
            )
            .animate()
            .fadeIn(delay: 1595.ms, duration: 605.ms, curve: _ease)
            .moveY(begin: 10, end: 0, duration: 605.ms, curve: _ease),
        const SizedBox(height: 8),
        ResponsiveText(
              'quiz.result.blessing',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyXLarge.copyWith(color: colors.dateSoft),
            )
            .animate()
            .fadeIn(delay: 1760.ms, duration: 605.ms, curve: _ease)
            .moveY(begin: 8, end: 0, duration: 605.ms, curve: _ease),
      ],
    );
  }

  // ─── Three-stat strip ────────────────────────────────────────────

  Widget _buildStats(AppColorsTheme colors) {
    final numStyle = AppTextStyles.headlineLarge.copyWith(
      fontWeight: FontWeight.w400,
      height: 1.0,
      letterSpacing: -0.3,
      color: colors.oliveDeep,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
          children: [
            Expanded(
              child: _StatCell(
                valueChild: RichText(
                  text: TextSpan(
                    style: numStyle,
                    children: [
                      TextSpan(text: '$_firstTryCorrect'),
                      TextSpan(
                        text: '/${widget.questionsCompleted}',
                        style: AppTextStyles.bodyMedium.copyWith(
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
            Expanded(
              child: _StatCell(
                valueChild: ResponsiveText(
                  widget.elapsed != null
                      ? _formatElapsed(widget.elapsed!)
                      : '—',
                  style: numStyle,
                ),
                label: 'quiz.result.stat_time',
                fallback: 'TIME',
                colors: colors,
              ),
            ),
            _Divider(colors: colors),
            Expanded(
              child: _StatCell(
                valueChild: ResponsiveText(
                  '+${widget.points}',
                  style: numStyle,
                ),
                label: 'quiz.result.stat_xp_earned',
                fallback: 'XP EARNED',
                colors: colors,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 1952.ms, duration: 605.ms, curve: _ease)
        .moveY(begin: 12, end: 0, duration: 605.ms, curve: _ease);
  }

  // ─── Olive CTA with looping shimmer ──────────────────────────────

  Widget _buildCta() {
    // Outer Animate plays the entrance once; the shimmer loop lives inside
    // ResultCtaButton and is hidden by this Opacity until entrance completes.
    return ResultCtaButton(onTap: widget.onDone)
        .animate()
        .fadeIn(delay: 2145.ms, duration: 605.ms, curve: _ease)
        .moveY(begin: 14, end: 0, duration: 605.ms, curve: _ease);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────

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
          ResponsiveText(
            resolved,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
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
