import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../theme/theme.dart';

// The celebration's motion — particle engine, trophy, rays and glow pool — lives
// in a part file so this entry point stays focused on layout and content.
part 'celebration_animation.dart';

/// Zad — **Level Complete Celebration**.
///
/// A victory moment: a gilded trophy that pops in with a checkmark draw,
/// spinning light rays and a soft glow pool behind it, a gentle confetti burst
/// and a soft fireworks volley, a near-imperceptible screen settle, count-up
/// XP, and three stat chips. It auto-plays on build.
///
/// Recreated from the `Zad Level Complete Celebration.html` design handoff. All
/// colours derive from the semantic theme ([context.appColors]) so it adapts to
/// both light and dark mode — gold accents on a warm cream vignette in light,
/// and on the roasted-brown Date & Ember canvas in dark.
///
/// It is purely presentational — feed it already-resolved content (the quiz
/// flow maps [QuizState] onto it in `ResultView`):
/// ```dart
/// LevelCompleteCelebration(
///   eyebrow: 'LEVEL 6 · COMPLETE',
///   title: 'Level Complete',
///   stats: const [
///     CelebrationStat(value: '10', suffix: '/10', label: 'Correct'),
///     CelebrationStat(value: '2:14', label: 'Time'),
///     CelebrationStat(value: '100', suffix: '%', label: 'Accuracy', fire: true),
///   ],
///   xp: 250,
///   onContinue: () => Navigator.of(context).pop(),
/// );
/// ```
class LevelCompleteCelebration extends StatelessWidget {
  const LevelCompleteCelebration({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.stats,
    required this.xp,
    this.arabic,
    this.subtitle,
    this.continueLabel = 'CONTINUE',
    this.onContinue,
    this.showBackButton = true,
  });

  /// Mono eyebrow above the title, e.g. `LEVEL 6 · COMPLETE`.
  final String eyebrow;

  /// Gilded headline, e.g. `Level Complete`.
  final String title;

  /// Up to three glass stat chips shown under the subtitle.
  final List<CelebrationStat> stats;

  /// Points earned — counts up from zero.
  final int xp;

  /// Optional Arabic blessing under the title.
  final String? arabic;

  /// Optional supporting line. Already localised by the caller; the column
  /// wraps it in the muted subtitle style.
  final Widget? subtitle;

  /// Primary button label.
  final String continueLabel;

  /// Primary action. Defaults to popping the current route.
  final VoidCallback? onContinue;

  /// Whether to show the standard top-start back control.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final palette = _CelPalette.of(context);

    return Material(
      color: palette.base,
      child: DecoratedBox(
        // Warm radial vignette over the page canvas.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.76),
            radius: 1.25,
            colors: [palette.bgTop, palette.bgMid, palette.bgBottom],
            stops: const [0.0, 0.46, 1.0],
          ),
        ),
        child: _CelebrationStage(
          data: this,
          palette: palette,
        ),
      ),
    );
  }
}

/// One glass stat chip in the celebration's stat strip.
class CelebrationStat {
  const CelebrationStat({
    required this.value,
    required this.label,
    this.suffix,
    this.fire = false,
  });

  /// The headline figure, e.g. `10`, `2:14`, `100`.
  final String value;

  /// Smaller trailing fragment baked into the figure, e.g. `/10`, `%`.
  final String? suffix;

  /// Caption under the figure, e.g. `Correct`.
  final String label;

  /// When true the figure is tinted ember instead of gold (the "on fire" cue).
  final bool fire;
}

// ─── Theme-derived palette ────────────────────────────────────────────────────

/// Every colour the celebration paints with, resolved once from the active
/// theme. Gold accents come from the amber [AppColorsTheme.accent] ramp; ember
/// and the confetti olive are brand constants shared across both brightnesses.
class _CelPalette {
  const _CelPalette({
    required this.isDark,
    required this.base,
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.creamHi,
    required this.titleHi,
    required this.titleMid,
    required this.titleLo,
    required this.ctaInk,
    required this.figure,
    required this.ember,
    required this.emberLight,
    required this.glow,
    required this.glowOpacity,
    required this.glassBorder,
    required this.confetti,
    required this.fireworks,
    required this.sparkWhite,
  });

  final bool isDark;
  final Color base;
  final Color bgTop, bgMid, bgBottom;
  final Color ink, muted, faint;
  final Color accent, accentSoft, accentDeep, creamHi;
  final Color titleHi, titleMid, titleLo, ctaInk;

  /// Gold used for text/figures painted directly on the page surface. Bright
  /// amber-light on the dark canvas; a deeper, saturated amber on the light
  /// canvas so the figures don't wash out against cream.
  final Color figure;

  final Color ember, emberLight;

  /// The warm halo behind the trophy + glow pool. Ember (fire) on the dark
  /// canvas; amber on the light canvas, where ember would read as a pink smudge.
  final Color glow;

  /// Scales the halo opacity down on the bright canvas so it stays a soft
  /// warmth instead of a heavy stain.
  final double glowOpacity;

  final Color glassBorder;
  final List<Color> confetti;
  final List<Color> fireworks;
  final Color sparkWhite;

  factory _CelPalette.of(BuildContext context) {
    final c = context.appColors;
    final dark = context.isDark;
    final gold = [c.accentSoft, c.accent, c.goldLight, c.accentDeep];
    const ember = [AppColors.emberBright, AppColors.ember];
    const olive = [AppColors.oliveLeaf, AppColors.oliveLight];

    return _CelPalette(
      isDark: dark,
      base: c.canvas,
      bgTop: c.backdropTop,
      bgMid: c.backdropMid,
      bgBottom: c.backdropBottom,
      ink: c.textPrimary,
      muted: c.textSecondary,
      faint: c.textTertiary,
      accent: c.accent,
      accentSoft: c.accentSoft,
      accentDeep: c.accentDeep,
      creamHi: c.goldLight,
      // Gilded title gradient: a light-on-dark sheen in dark mode, a deeper
      // gold→bronze gilt in light mode so it stays legible on cream.
      titleHi: dark ? c.goldLight : c.accent,
      titleMid: dark ? c.accentSoft : c.accentDeep,
      titleLo: dark ? c.accentDeep : c.goldDark,
      figure: dark ? c.accentSoft : c.accentDeep,
      ctaInk: c.goldInk,
      ember: AppColors.ember,
      emberLight: AppColors.emberBright,
      glow: dark ? AppColors.ember : c.accent,
      glowOpacity: dark ? 1.0 : 0.5,
      glassBorder: c.accent.withValues(alpha: 0.30),
      confetti: [...gold, ...ember, ...olive, c.textPrimary],
      fireworks: [...gold, ...ember],
      sparkWhite: c.goldLight,
    );
  }
}

// Shared entrance curve, mirroring the prototype's ease-out reveals.
const _ease = Curves.easeOutCubic;

// ─── Stage ────────────────────────────────────────────────────────────────

class _CelebrationStage extends StatefulWidget {
  const _CelebrationStage({required this.data, required this.palette});

  final LevelCompleteCelebration data;
  final _CelPalette palette;

  @override
  State<_CelebrationStage> createState() => _CelebrationStageState();
}

class _CelebrationStageState extends State<_CelebrationStage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _Fx _fx;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  final List<Future<void>> _pending = [];
  bool _disposed = false;

  Size _lastSize = const Size(392, 812);

  @override
  void initState() {
    super.initState();
    _fx = _Fx(widget.palette);
    _ticker = createTicker(_onTick)..start();

    // Confetti burst on trophy impact (single gentle pop).
    _schedule(400, () => _fx.burstConfetti(_lastSize));
    // One soft firework, then a slow volley that tapers off after ~2.4s.
    _schedule(750, () {
      _fx.launchRocket(_lastSize);
      _schedule(1100, () => _fx.launchRocket(_lastSize));
      _schedule(2200, () => _fx.launchRocket(_lastSize));
    });
  }

  void _schedule(int ms, VoidCallback fn) {
    final f = Future<void>.delayed(Duration(milliseconds: ms), () {
      if (!_disposed) fn();
    });
    _pending.add(f);
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_fx.step(dt.clamp(0.0, 1 / 30), _lastSize)) {
      _frame.value++;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final data = widget.data;
    final p = widget.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Spinning rays + glow pool, centred behind the trophy.
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.30),
                child: _RaysLayer(palette: p),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.30),
                child: _PoolLayer(palette: p),
              ),
            ),
            // Fireworks — behind the content (z8).
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _FireworksPainter(_fx, palette: p, repaint: _frame),
                ),
              ),
            ),
            // Content column (z20) — settles with a near-imperceptible shake.
            Positioned.fill(
              child: _ContentColumn(data: data, palette: p),
            ),
            // Confetti — above the content (z30).
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ConfettiPainter(_fx, repaint: _frame),
                ),
              ),
            ),
            // Action pinned to the bottom (z40).
            Positioned(
              left: 30,
              right: 30,
              bottom: 24 + padding.bottom,
              child: _Actions(
                label: data.continueLabel,
                palette: p,
                onContinue: () => (data.onContinue ??
                    () => Navigator.of(context).maybePop())(),
              ),
            ),
            // Standard back control (z50).
            if (data.showBackButton)
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ZaadCircleIconButton.back(
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Content column (trophy, eyebrow, title, chips, XP) ──────────────────────

class _ContentColumn extends StatelessWidget {
  const _ContentColumn({required this.data, required this.palette});

  final LevelCompleteCelebration data;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final arabic = data.arabic;
    final subtitle = data.subtitle;

    final column = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Trophy(palette: palette),
          const SizedBox(height: 14),
          _eyebrow(),
          const SizedBox(height: 8),
          _title(),
          if (arabic != null && arabic.isNotEmpty) ...[
            const SizedBox(height: 6),
            _arabic(arabic),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            _subtitle(subtitle),
          ],
          const SizedBox(height: 24),
          _chips(),
          const SizedBox(height: 20),
          _xp(),
        ],
      ),
    );

    // Settle the whole stage on trophy impact — a quiet shake, not a slam.
    return column.animate().shake(
          delay: 350.ms,
          duration: 620.ms,
          hz: 5,
          offset: const Offset(1.4, 0.8),
          rotation: 0,
        );
  }

  Widget _eyebrow() => Text(
        data.eyebrow.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
          color: palette.figure,
          height: 1.2,
        ),
      ).animate().fadeIn(delay: 1150.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1150.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _title() => ShaderMask(
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.titleHi, palette.titleMid, palette.titleLo],
          stops: const [0.0, 0.46, 1.0],
        ).createShader(rect),
        child: Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 0.98,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 1250.ms, duration: 700.ms, curve: _ease)
          .scaleXY(
            begin: 0.92,
            end: 1,
            delay: 1250.ms,
            duration: 700.ms,
            curve: Curves.easeOutBack,
          )
          .moveY(
            begin: 16,
            end: 0,
            delay: 1250.ms,
            duration: 700.ms,
            curve: _ease,
          );

  Widget _arabic(String text) => Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: palette.accent,
          height: 1.2,
        ),
      ).animate().fadeIn(delay: 1450.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1450.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _subtitle(Widget child) => DefaultTextStyle(
        style: TextStyle(
          fontSize: 13.5,
          height: 1.5,
          color: palette.muted,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 264),
          child: child,
        ),
      ).animate().fadeIn(delay: 1600.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1600.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _chips() {
    final chips = data.stats.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _StatChip(
            stat: chips[i],
            palette: palette,
            delayMs: 1700 + i * 120,
          ),
        ],
      ],
    );
  }

  Widget _xp() => _XpCounter(to: data.xp, palette: palette)
      .animate()
      .fadeIn(delay: 2050.ms, duration: 600.ms, curve: _ease)
      .moveY(begin: 12, end: 0, delay: 2050.ms, duration: 600.ms, curve: _ease);
}

// ─── Stat chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.stat,
    required this.palette,
    required this.delayMs,
  });

  final CelebrationStat stat;
  final _CelPalette palette;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final figure = stat.fire ? palette.emberLight : palette.figure;

    return Container(
      constraints: const BoxConstraints(minWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.glassBorder),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.ink.withValues(alpha: 0.07),
            palette.ink.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: stat.value,
                  style: TextStyle(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    height: 1,
                    color: figure,
                  ),
                ),
                if (stat.suffix != null)
                  TextSpan(
                    text: stat.suffix,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: figure.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: palette.muted,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 550.ms, curve: _ease)
        .scaleXY(
          begin: 0.9,
          end: 1,
          delay: delayMs.ms,
          duration: 550.ms,
          curve: Curves.easeOutBack,
        )
        .moveY(
          begin: 16,
          end: 0,
          delay: delayMs.ms,
          duration: 550.ms,
          curve: _ease,
        );
  }
}

// ─── XP count-up ─────────────────────────────────────────────────────────────

class _XpCounter extends StatefulWidget {
  const _XpCounter({required this.to, required this.palette});

  final int to;
  final _CelPalette palette;

  @override
  State<_XpCounter> createState() => _XpCounterState();
}

class _XpCounterState extends State<_XpCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _count;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _count = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future<void>.delayed(const Duration(milliseconds: 2050), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'EARNED',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.8,
            color: p.faint,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _count,
          builder: (context, _) {
            final shown = (widget.to * _count.value).round();
            return Text(
              '+$shown XP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: p.figure,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Action ──────────────────────────────────────────────────────────────────

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onContinue,
    required this.label,
    required this.palette,
  });

  final VoidCallback onContinue;
  final String label;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    return _GoldButton(onTap: onContinue, label: label, palette: palette)
        .animate()
        .fadeIn(delay: 2200.ms, duration: 600.ms, curve: _ease)
        .moveY(
          begin: 18,
          end: 0,
          delay: 2200.ms,
          duration: 600.ms,
          curve: _ease,
        );
  }
}

class _GoldButton extends StatefulWidget {
  const _GoldButton({
    required this.onTap,
    required this.label,
    required this.palette,
  });

  final VoidCallback onTap;
  final String label;
  final _CelPalette palette;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    Future<void>.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) _shine.repeat();
    });
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.accentSoft, p.accent, p.accentDeep],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: 0.36),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Looping shine sweep.
              AnimatedBuilder(
                animation: _shine,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(
                    (_shine.value / 0.22).clamp(0.0, 1.0),
                  );
                  return Positioned.fill(
                    child: FractionalTranslation(
                      translation: Offset(-0.6 + 2.0 * t, 0),
                      child: Transform(
                        transform: Matrix4.skewX(-0.32),
                        alignment: Alignment.center,
                        child: FractionallySizedBox(
                          widthFactor: 0.4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.5),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.9,
                      color: p.ctaInk,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: p.ctaInk,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
