import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Zad — **Team Number One Celebration** dialog.
///
/// A "#1 in the team" moment: a crowned gold medallion pops above a glass card,
/// a sunburst spins behind it, the crown drops, twinkles and orbiting sparkles
/// shimmer, confetti rains, then the title, an Arabic blessing, a stat trio and
/// the actions rise in — all over a blurred leaderboard.
///
/// Recreated from the `Zad Team Number One Celebration.html` design handoff.
/// Colours derive from the semantic theme ([context.appColors]) so the card
/// adapts to both brightnesses while the gilded medallion stays gold.
class TeamNumberOneCelebrationDialog extends StatelessWidget {
  const TeamNumberOneCelebrationDialog({
    super.key,
    required this.teamName,
    required this.companions,
    required this.leaderName,
    required this.points,
    required this.accuracy,
    required this.streak,
    this.rank = 1,
    this.onShare,
    this.onBack,
  });

  /// Team the leader topped, e.g. `Companions of Sabr`.
  final String teamName;

  /// Companions led this week — folded into the subtitle.
  final int companions;

  /// Leader's display name — its first glyph is stamped on the medallion coin.
  final String leaderName;

  final int points;
  final int accuracy;
  final int streak;

  /// Rank reached (the ribbon badge under the coin). Defaults to 1.
  final int rank;

  final VoidCallback? onShare;
  final VoidCallback? onBack;

  static Future<T?> show<T>({
    required BuildContext context,
    String teamName = 'Companions of Sabr',
    int companions = 11,
    String leaderName = 'Zayd N.',
    int points = 3480,
    int accuracy = 96,
    int streak = 38,
    int rank = 1,
    VoidCallback? onShare,
    VoidCallback? onBack,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) => TeamNumberOneCelebrationDialog(
        teamName: teamName,
        companions: companions,
        leaderName: leaderName,
        points: points,
        accuracy: accuracy,
        streak: streak,
        rank: rank,
        onShare: onShare,
        onBack: onBack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _CelPalette.of(context);
    return _CelebrationStage(data: this, palette: p);
  }
}

// ─── Theme-derived palette ──────────────────────────────────────────────────

/// Every colour the celebration paints with, resolved once from the theme.
class _CelPalette {
  const _CelPalette({
    required this.isDark,
    required this.cardTop,
    required this.cardBottom,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.goldLight,
    required this.goldInk,
    required this.titleHi,
    required this.titleMid,
    required this.titleLo,
    required this.ember,
    required this.emberLight,
    required this.glow,
    required this.glowOpacity,
    required this.hairline,
    required this.glassBorder,
    required this.crown,
    required this.confetti,
  });

  final bool isDark;
  final Color cardTop, cardBottom;
  final Color ink, muted, faint;
  final Color accent, accentSoft, accentDeep, goldLight, goldInk;
  final Color titleHi, titleMid, titleLo;
  final Color ember, emberLight;
  final Color glow;
  final double glowOpacity;
  final Color hairline, glassBorder, crown;
  final List<Color> confetti;

  factory _CelPalette.of(BuildContext context) {
    final c = context.appColors;
    final dark = context.isDark;
    return _CelPalette(
      isDark: dark,
      cardTop: c.creamSurfaceTop,
      cardBottom: c.creamSurfaceBottom,
      ink: c.textPrimary,
      muted: c.textSecondary,
      faint: c.textTertiary,
      accent: c.accent,
      accentSoft: c.accentSoft,
      accentDeep: c.accentDeep,
      goldLight: c.goldLight,
      goldInk: c.goldInk,
      titleHi: dark ? c.goldLight : c.accent,
      titleMid: dark ? c.accentSoft : c.accentDeep,
      titleLo: dark ? c.accentDeep : c.goldDark,
      ember: AppColors.ember,
      emberLight: AppColors.emberBright,
      glow: dark ? AppColors.ember : c.accent,
      glowOpacity: dark ? 1.0 : 0.6,
      hairline: c.borderSubtle,
      glassBorder: c.accent.withValues(alpha: 0.22),
      crown: c.accentSoft,
      confetti: [
        c.accentSoft,
        c.accent,
        c.goldLight,
        c.accentDeep,
        AppColors.emberBright,
        AppColors.oliveLeaf,
        c.textPrimary,
      ],
    );
  }
}

// Shared entrance curve, mirroring the prototype's ease-out reveals.
const _ease = Curves.easeOutCubic;
const _pop = Curves.easeOutBack;

// ─── Full-screen stage (blur + scrim + confetti + dialog) ────────────────────

class _CelebrationStage extends StatefulWidget {
  const _CelebrationStage({required this.data, required this.palette});

  final TeamNumberOneCelebrationDialog data;
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
  bool _disposed = false;
  bool _started = false;

  Size _screen = const Size(392, 812);

  @override
  void initState() {
    super.initState();
    _fx = _Fx(widget.palette.confetti);
    _ticker = createTicker(_onTick)..start();
    // Two soft confetti volleys, mirroring the prototype.
    _schedule(420, () => _fx.burst(_screen));
    _schedule(1150, () => _fx.burst(_screen));
  }

  void _schedule(int ms, VoidCallback fn) {
    Future<void>.delayed(Duration(milliseconds: ms), () {
      if (!_disposed) {
        fn();
        _started = true;
      }
    });
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_started && _fx.step(dt.clamp(0.0, 1 / 30), _screen)) {
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
    final p = widget.palette;
    _screen = MediaQuery.sizeOf(context);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blurred + dimmed leaderboard behind, dismiss on tap.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.16),
                      radius: 1.0,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.86),
                      ],
                      stops: const [0.0, 0.72],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confetti — behind the dialog card (z36 in the prototype).
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ConfettiPainter(_fx, repaint: _frame),
                ),
              ),
            ),
          ),
          // The celebration dialog.
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 80, 26, 40),
              child: _Dialog(data: widget.data, palette: p),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dialog card ──────────────────────────────────────────────────────────────

class _Dialog extends StatelessWidget {
  const _Dialog({required this.data, required this.palette});

  final TeamNumberOneCelebrationDialog data;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    const radius = 30.0;

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.cardTop, p.cardBottom],
        ),
        border: Border.all(color: p.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: p.accentSoft.withValues(alpha: 0.24),
            blurRadius: 0.6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Clipped decoration: top amber glow, faint pattern, rising motes.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -1),
                        radius: 1.05,
                        colors: [
                          p.accent.withValues(alpha: 0.24),
                          p.accent.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.52],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.06,
                    child: Image.asset(
                      'assets/images/islamic-pattern.png',
                      repeat: ImageRepeat.repeat,
                      alignment: Alignment.topLeft,
                      color: p.ink,
                      colorBlendMode: BlendMode.screen,
                    ),
                  ),
                  _Motes(palette: p),
                ],
              ),
            ),
          ),
          // Content.
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reserve the lower half of the lifted medallion.
                const SizedBox(height: 78),
                _ribbon(p),
                const SizedBox(height: 11),
                _title(p),
                const SizedBox(height: 4),
                _arabic(p),
                const SizedBox(height: 11),
                _subtitle(p),
                const SizedBox(height: 18),
                _trio(p),
                const SizedBox(height: 20),
                _buttons(context, p),
              ],
            ),
          ),
          // Medallion lifted above the card top.
          Positioned(
            top: -58,
            child: _Medallion(palette: p, initial: _initial),
          ),
        ],
      ),
    );

    // Card entrance: scale-up with a soft elastic settle.
    return card
        .animate()
        .fadeIn(delay: 150.ms, duration: 400.ms, curve: _ease)
        .scaleXY(begin: 0.86, end: 1, delay: 150.ms, duration: 700.ms, curve: _pop);
  }

  String get _initial {
    final t = data.leaderName.trim();
    return t.isEmpty ? '?' : t.characters.first;
  }

  Widget _ribbon(_CelPalette p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: p.ember.withValues(alpha: 0.16),
          border: Border.all(color: p.emberLight.withValues(alpha: 0.42)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Crown(color: p.emberLight, width: 10),
            const SizedBox(width: 6),
            ResponsiveText(
              'teams.number_one.eyebrow'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.1,
                color: p.emberLight,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1200.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1200.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _title(_CelPalette p) => ShaderMask(
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.titleHi, p.titleMid, p.titleLo],
          stops: const [0.0, 0.46, 1.0],
        ).createShader(rect),
        child: ResponsiveText(
          'teams.number_one.title',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 0.98,
            letterSpacing: -1.1,
            color: Colors.white,
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 1300.ms, duration: 700.ms, curve: _ease)
          .scaleXY(begin: 0.94, end: 1, delay: 1300.ms, duration: 700.ms, curve: _pop)
          .moveY(begin: 14, end: 0, delay: 1300.ms, duration: 700.ms, curve: _ease);

  Widget _arabic(_CelPalette p) => ResponsiveText(
        'teams.number_one.arabic',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.accent,
          height: 1.2,
        ),
      ).animate().fadeIn(delay: 1500.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1500.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _subtitle(_CelPalette p) => DefaultTextStyle(
        style: TextStyle(
          fontSize: 12.5,
          height: 1.5,
          color: p.muted,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${'teams.number_one.subtitle_prefix'.tr()} '),
                TextSpan(
                  text: data.teamName,
                  style: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: 'teams.number_one.subtitle_suffix'
                      .tr(namedArgs: {'count': '${data.companions}'}),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ).animate().fadeIn(delay: 1620.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1620.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _trio(_CelPalette p) {
    final cells = [
      _StatCell(
        value: _formatInt(data.points),
        label: 'teams.number_one.stat_points'.tr(),
        palette: p,
        delayMs: 1740,
      ),
      _StatCell(
        value: '${data.accuracy}',
        suffix: '%',
        label: 'teams.number_one.stat_accuracy'.tr(),
        palette: p,
        delayMs: 1840,
      ),
      _StatCell(
        value: '${data.streak}',
        label: 'teams.number_one.stat_streak'.tr(),
        palette: p,
        fire: true,
        delayMs: 1940,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(child: cells[i]),
        ],
      ],
    );
  }

  Widget _buttons(BuildContext context, _CelPalette p) => Column(
        children: [
          _GoldButton(
            label: 'teams.number_one.share_cta'.tr(),
            palette: p,
            onTap: () =>
                (data.onShare ?? () => Navigator.of(context).maybePop())(),
          ),
          const SizedBox(height: 10),
          _GhostButton(
            prefix: 'teams.number_one.back_prefix'.tr(),
            word: 'teams.number_one.back_word'.tr(),
            palette: p,
            onTap: () =>
                (data.onBack ?? () => Navigator.of(context).maybePop())(),
          ),
        ],
      ).animate().fadeIn(delay: 2050.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 16,
            end: 0,
            delay: 2050.ms,
            duration: 600.ms,
            curve: _ease,
          );

  static String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Medallion (coin + crown + rays + halo + orbits + twinkles + badge) ───────

class _Medallion extends StatelessWidget {
  const _Medallion({required this.palette, required this.initial});

  final _CelPalette palette;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Spinning sunburst.
          Positioned.fill(
            child: OverflowBox(
              maxWidth: 198,
              maxHeight: 198,
              child: _Rays(palette: p),
            ),
          ),
          // Counter-rotating orbiting sparkle dots.
          _OrbitDot(palette: p, period: 5000, reverse: false, dot: 6),
          _OrbitDot(palette: p, period: 6500, reverse: true, dot: 4),
          // Pulsing halo.
          _Halo(palette: p),
          // Coin.
          _Coin(palette: p, initial: initial),
          // Twinkles.
          ..._twinkles(p),
          // Crown dropping on the coin.
          Positioned(
            top: -12,
            child: _Crown(color: p.crown, width: 40)
                .animate()
                .fadeIn(delay: 950.ms, duration: 220.ms)
                .scaleXY(begin: 0.4, end: 1, delay: 950.ms, duration: 750.ms, curve: Curves.elasticOut)
                .moveY(begin: -20, end: 0, delay: 950.ms, duration: 750.ms, curve: _pop)
                .rotate(begin: -0.08, end: 0, delay: 950.ms, duration: 750.ms, curve: _pop),
          ),
          // #1 ribbon badge under the coin.
          Positioned(
            bottom: -6,
            child: _RankBadge(palette: p)
                .animate()
                .scaleXY(begin: 0, end: 1, delay: 1150.ms, duration: 500.ms, curve: Curves.elasticOut),
          ),
        ],
      ),
    );
  }

  List<Widget> _twinkles(_CelPalette p) {
    const specs = [
      (top: -6.0, left: 6.0, right: null, bottom: null, size: 14.0, delay: 1200),
      (top: 8.0, left: null, right: -4.0, bottom: null, size: 10.0, delay: 1600),
      (top: null, left: -10.0, right: null, bottom: 18.0, size: 12.0, delay: 1900),
      (top: -2.0, left: null, right: 24.0, bottom: null, size: 9.0, delay: 2300),
      (top: null, left: null, right: 14.0, bottom: 6.0, size: 11.0, delay: 2000),
    ];
    return [
      for (final s in specs)
        Positioned(
          top: s.top,
          left: s.left,
          right: s.right,
          bottom: s.bottom,
          child: _Twinkle(color: p.goldLight, size: s.size, delayMs: s.delay),
        ),
    ];
  }
}

// ─── Coin ─────────────────────────────────────────────────────────────────────

class _Coin extends StatefulWidget {
  const _Coin({required this.palette, required this.initial});

  final _CelPalette palette;
  final String initial;

  @override
  State<_Coin> createState() => _CoinState();
}

class _CoinState extends State<_Coin> with TickerProviderStateMixin {
  late final AnimationController _float;
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        _float.repeat(reverse: true);
        _shine.forward();
      }
    });
  }

  @override
  void dispose() {
    _float.dispose();
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy = -5 * Curves.easeInOut.transform(_float.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.32, -0.48),
            colors: [
              AppColors.medallionHighlight,
              p.goldLight,
              p.accent,
              p.accentDeep,
            ],
            stops: const [0.0, 0.38, 0.62, 1.0],
          ),
          boxShadow: [
            BoxShadow(color: p.goldLight.withValues(alpha: 0.6), spreadRadius: 2),
            BoxShadow(
              color: AppColors.ember.withValues(alpha: 0.46),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ResponsiveText(
                widget.initial,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: p.goldInk,
                  height: 1,
                ),
              ),
              // One-shot diagonal shine sweep.
              AnimatedBuilder(
                animation: _shine,
                builder: (context, _) {
                  if (_shine.value == 0 || _shine.isCompleted) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: FractionalTranslation(
                      translation: Offset(-0.8 + 2.0 * _shine.value, 0),
                      child: Transform.rotate(
                        angle: 0.32,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.6),
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
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 350.ms, duration: 300.ms)
        .scaleXY(begin: 0, end: 1, delay: 350.ms, duration: 800.ms, curve: Curves.elasticOut)
        .rotate(begin: -0.066, end: 0, delay: 350.ms, duration: 800.ms, curve: _pop);
  }
}

// ─── Rays (spinning sunburst) ─────────────────────────────────────────────────

class _Rays extends StatefulWidget {
  const _Rays({required this.palette});

  final _CelPalette palette;

  @override
  State<_Rays> createState() => _RaysState();
}

class _RaysState extends State<_Rays> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _spin.repeat();
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) => Transform.rotate(
        angle: _spin.value * 2 * math.pi,
        child: CustomPaint(
          size: const Size(198, 198),
          painter: _RaysPainter(widget.palette.goldLight),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 800.ms, curve: _ease);
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final spike = color.withValues(alpha: 0.30);
    final clear = color.withValues(alpha: 0);

    final colors = <Color>[];
    final stops = <double>[];
    const n = 12;
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
        ..shader = SweepGradient(colors: colors, stops: stops).createShader(rect),
    );
    // Ring mask: transparent core, solid mid band, transparent rim.
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = RadialGradient(
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0),
            Colors.white,
            Colors.white,
            AppColors.white.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.44, 0.5, 0.74, 0.82],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => oldDelegate.color != color;
}

// ─── Halo (pulsing glow) ──────────────────────────────────────────────────────

class _Halo extends StatefulWidget {
  const _Halo({required this.palette});

  final _CelPalette palette;

  @override
  State<_Halo> createState() => _HaloState();
}

class _HaloState extends State<_Halo> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Transform.scale(
          scale: 1 + 0.08 * t,
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  p.accent.withValues(alpha: (0.5 + 0.1 * t) * p.glowOpacity),
                  p.accent.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.72],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 400.ms, duration: 700.ms, curve: _ease);
  }
}

// ─── Orbiting sparkle dot ─────────────────────────────────────────────────────

class _OrbitDot extends StatefulWidget {
  const _OrbitDot({
    required this.palette,
    required this.period,
    required this.reverse,
    required this.dot,
  });

  final _CelPalette palette;
  final int period;
  final bool reverse;
  final double dot;

  @override
  State<_OrbitDot> createState() => _OrbitDotState();
}

class _OrbitDotState extends State<_OrbitDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.period),
    );
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _spin.repeat();
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        final dir = widget.reverse ? -1 : 1;
        return Transform.rotate(
          angle: dir * _spin.value * 2 * math.pi,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: widget.dot,
                height: widget.dot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.medallionHighlight, p.accent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: p.goldLight.withValues(alpha: 0.9),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 1100.ms, duration: 600.ms, curve: _ease);
  }
}

// ─── Twinkling star ───────────────────────────────────────────────────────────

class _Twinkle extends StatefulWidget {
  const _Twinkle({
    required this.color,
    required this.size,
    required this.delayMs,
  });

  final Color color;
  final double size;
  final int delayMs;

  @override
  State<_Twinkle> createState() => _TwinkleState();
}

class _TwinkleState extends State<_Twinkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Triangle peak at 45% of the cycle, per the prototype keyframe.
        final v = _c.value;
        final t = v < 0.45 ? v / 0.45 : (1 - v) / 0.55;
        final e = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
        return Opacity(
          opacity: e,
          child: Transform.rotate(
            angle: 0.35 * e,
            child: Transform.scale(
              scale: 0.3 + 0.7 * e,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _StarPainter(widget.color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Four-point sparkle on a 24×24 viewBox.
    final s = size.width / 24;
    final path = Path()
      ..moveTo(12 * s, 2 * s)
      ..lineTo(14 * s, 9 * s)
      ..lineTo(21 * s, 12 * s)
      ..lineTo(14 * s, 15 * s)
      ..lineTo(12 * s, 22 * s)
      ..lineTo(10 * s, 15 * s)
      ..lineTo(3 * s, 12 * s)
      ..lineTo(10 * s, 9 * s)
      ..close();
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.color != color;
}

// ─── #1 ribbon badge ──────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.palette});

  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.emberLight, p.ember],
        ),
        border: Border.all(color: p.cardBottom, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: p.ember.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ResponsiveText(
        '#1',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.emberInk,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Rising light motes ───────────────────────────────────────────────────────

class _Motes extends StatefulWidget {
  const _Motes({required this.palette});

  final _CelPalette palette;

  @override
  State<_Motes> createState() => _MotesState();
}

class _MotesState extends State<_Motes> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Mote> _motes;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _motes = List.generate(10, (i) {
      return _Mote(
        x: 0.06 + rng.nextDouble() * 0.88,
        phase: rng.nextDouble(),
        speed: 0.6 + rng.nextDouble() * 0.5,
        size: 2.4 + rng.nextDouble() * 2.4,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MotesPainter(_motes, _c, widget.palette.accentSoft),
      ),
    );
  }
}

class _Mote {
  _Mote({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
  });

  final double x, phase, speed, size;
}

class _MotesPainter extends CustomPainter {
  _MotesPainter(this.motes, this.anim, this.color) : super(repaint: anim);

  final List<_Mote> motes;
  final Animation<double> anim;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint();
    for (final m in motes) {
      final t = (anim.value * m.speed + m.phase) % 1.0;
      final y = size.height - t * (size.height + 40);
      // Opacity: ramp up, hold, fade — peaks in the middle of the rise.
      final a = (t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 0.7))
          .clamp(0.0, 0.7);
      paint.color = color.withValues(alpha: a);
      canvas.drawCircle(Offset(m.x * size.width, y), m.size, paint);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter oldDelegate) => false;
}

// ─── Crown glyph ──────────────────────────────────────────────────────────────

/// The eight-point crown from the design, painted from the prototype's path.
class _Crown extends StatelessWidget {
  const _Crown({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width * 24 / 36),
        painter: _CrownPainter(color),
      );
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 36;
    final sy = size.height / 24;
    canvas.save();
    canvas.scale(sx, sy);

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final body = Path()
      ..moveTo(2, 21)
      ..lineTo(34, 21)
      ..lineTo(31.5, 6)
      ..lineTo(24, 12)
      ..lineTo(18, 2)
      ..lineTo(12, 12)
      ..lineTo(4.5, 6)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawCircle(const Offset(3, 4.5), 2.4, paint);
    canvas.drawCircle(const Offset(33, 4.5), 2.4, paint);
    canvas.drawCircle(const Offset(18, 2.4), 2.4, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) => oldDelegate.color != color;
}

// ─── Stat cell ────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.palette,
    required this.delayMs,
    this.suffix,
    this.fire = false,
  });

  final String value;
  final String? suffix;
  final String label;
  final _CelPalette palette;
  final int delayMs;
  final bool fire;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final figure = fire ? p.emberLight : p.accentSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: p.ink.withValues(alpha: 0.04),
        border: Border.all(color: p.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 21,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: figure,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: figure,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ResponsiveText(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: p.muted,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 500.ms, curve: _ease)
        .scaleXY(begin: 0.92, end: 1, delay: delayMs.ms, duration: 500.ms, curve: _pop)
        .moveY(begin: 14, end: 0, delay: delayMs.ms, duration: 500.ms, curve: _ease);
  }
}

// ─── Buttons ──────────────────────────────────────────────────────────────────

class _GoldButton extends StatefulWidget {
  const _GoldButton({
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final _CelPalette palette;
  final VoidCallback onTap;

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
      duration: const Duration(milliseconds: 3600),
    );
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
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
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.goldLight, p.accent, p.accentDeep],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: 0.34),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _shine,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(
                    (_shine.value / 0.24).clamp(0.0, 1.0),
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
                  ResponsiveText(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: p.goldInk,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icon(Icons.ios_share_rounded, size: 14, color: p.goldInk),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.prefix,
    required this.word,
    required this.palette,
    required this.onTap,
  });

  final String prefix;
  final String word;
  final _CelPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${prefix.toUpperCase()} '),
              TextSpan(
                text: word.toUpperCase(),
                style: TextStyle(
                  color: p.accentSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.3,
            color: p.muted,
          ),
        ),
      ),
    );
  }
}

// ─── Confetti particle engine ────────────────────────────────────────────────

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

/// Holds and advances the confetti particles. Stepped in fixed 1/60 substeps so
/// the tuned per-frame constants behave the same on any refresh rate.
class _Fx {
  _Fx(this.colors);

  final List<Color> colors;
  final List<_Confetto> confetti = [];
  final math.Random _rng = math.Random();

  double _acc = 0;
  static const double _stepDt = 1 / 60;

  double _rnd(double a, double b) => a + _rng.nextDouble() * (b - a);
  Color _pick() => colors[_rng.nextInt(colors.length)];

  void burst(Size size) {
    final w = size.width;
    final cx = w / 2;
    final cy = size.height * 0.34;
    for (var i = 0; i < 56; i++) {
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
        col: _pick(),
        decay: _rnd(0.006, 0.012),
        ribbon: _rng.nextDouble() < 0.7,
      ));
    }
    for (var i = 0; i < 20; i++) {
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
        col: _pick(),
        decay: _rnd(0.004, 0.007),
        ribbon: false,
      ));
    }
  }

  /// Advances the simulation; returns true when anything is still alive.
  bool step(double dt, Size size) {
    _acc += dt;
    var stepped = false;
    while (_acc >= _stepDt) {
      _acc -= _stepDt;
      _advance(size);
      stepped = true;
    }
    return stepped && confetti.isNotEmpty;
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
  }
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
