import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../theme/theme.dart';

/// One row in the team leaderboard shown behind the celebration banner.
class TeamLeaderEntry {
  const TeamLeaderEntry({
    required this.rank,
    required this.name,
    required this.accuracy,
    required this.streak,
    required this.points,
    this.isMe = false,
  });

  final int rank;
  final String name;
  final int accuracy;
  final int streak;
  final int points;

  /// The companion who just rose to #1 — gets the gilded row + crown.
  final bool isMe;
}

/// Zad — **Team Number One Celebration**.
///
/// A calm "#1 in the team" moment shown as a dialog: a crown drops onto the
/// leader's avatar, a soft confetti burst and a warm glow pool bloom, and the
/// banner ("New team leader · You're #1!") rises over the dimmed leaderboard.
///
/// Recreated from the `Zad Team Number One Celebration.html` design handoff.
/// Every colour derives from the semantic theme ([context.appColors]) so it
/// adapts to both brightnesses — gold accents on the roasted-brown Date & Ember
/// surface in dark, and on a warm cream surface in light.
class TeamNumberOneCelebrationDialog extends StatelessWidget {
  const TeamNumberOneCelebrationDialog({
    super.key,
    required this.teamName,
    required this.companions,
    required this.entries,
    this.onShare,
    this.onViewLeaderboard,
  });

  /// Team the leader topped, e.g. `Companions of Sabr`.
  final String teamName;

  /// Companions led this week — folded into the subtitle.
  final int companions;

  /// The leaderboard rows (top-down). Exactly one should be marked [isMe].
  final List<TeamLeaderEntry> entries;

  final VoidCallback? onShare;
  final VoidCallback? onViewLeaderboard;

  /// The design's sample roster — used by the home preview trigger and as a
  /// sensible default while the real ranking loads.
  static const List<TeamLeaderEntry> sampleEntries = [
    TeamLeaderEntry(
      rank: 1,
      name: 'Zayd N.',
      accuracy: 96,
      streak: 38,
      points: 3480,
      isMe: true,
    ),
    TeamLeaderEntry(rank: 2, name: 'Yūsuf A.', accuracy: 94, streak: 36, points: 3420),
    TeamLeaderEntry(rank: 3, name: 'Aisha M.', accuracy: 91, streak: 24, points: 2980),
    TeamLeaderEntry(rank: 4, name: 'Maryam K.', accuracy: 89, streak: 16, points: 2210),
  ];

  static Future<T?> show<T>({
    required BuildContext context,
    String teamName = 'Companions of Sabr',
    int companions = 11,
    List<TeamLeaderEntry> entries = sampleEntries,
    VoidCallback? onShare,
    VoidCallback? onViewLeaderboard,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => TeamNumberOneCelebrationDialog(
        teamName: teamName,
        companions: companions,
        entries: entries,
        onShare: onShare,
        onViewLeaderboard: onViewLeaderboard,
      ),
    );
  }

  static const double _border = 1.6;
  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final p = _CelPalette.of(context);
    final maxHeight = math.min(MediaQuery.sizeOf(context).height * 0.86, 612.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.06,
        vertical: 24,
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.92, end: 1),
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          padding: const EdgeInsets.all(_border),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            // Gilded amber→ivory hairline frame, matching CustomDialog.
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: const [0.35, 0.9],
              colors: [p.accent.withValues(alpha: 0.55), p.hairline],
            ),
            boxShadow: [
              BoxShadow(
                color: p.glow.withValues(alpha: 0.22),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius - _border),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: _CelebrationStage(data: this, palette: p),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Theme-derived palette ──────────────────────────────────────────────────

/// Every colour the celebration paints with, resolved once from the active
/// theme so the dialog reads correctly in both brightnesses.
class _CelPalette {
  const _CelPalette({
    required this.isDark,
    required this.surfaceTop,
    required this.surfaceBottom,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
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
  final Color surfaceTop, surfaceBottom;
  final Color ink, muted, faint;
  final Color accent, accentSoft, accentDeep, goldInk;
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
      surfaceTop: c.creamSurfaceTop,
      surfaceBottom: c.creamSurfaceBottom,
      ink: c.textPrimary,
      muted: c.textSecondary,
      faint: c.textTertiary,
      accent: c.accent,
      accentSoft: c.accentSoft,
      accentDeep: c.accentDeep,
      goldInk: c.goldInk,
      // Gilded title gradient: a light-on-dark sheen in dark mode, a deeper
      // gold→bronze gilt in light mode so it stays legible on cream.
      titleHi: dark ? c.goldLight : c.accent,
      titleMid: dark ? c.accentSoft : c.accentDeep,
      titleLo: dark ? c.accentDeep : c.goldDark,
      ember: AppColors.ember,
      emberLight: AppColors.emberBright,
      glow: dark ? AppColors.ember : c.accent,
      glowOpacity: dark ? 1.0 : 0.55,
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

// ─── Stage ──────────────────────────────────────────────────────────────────

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
  bool _burst = false;

  Size _lastSize = const Size(340, 600);

  @override
  void initState() {
    super.initState();
    _fx = _Fx(widget.palette.confetti);
    _ticker = createTicker(_onTick)..start();
    // Soft confetti pop just after the crown lands.
    Future<void>.delayed(const Duration(milliseconds: 560), () {
      if (!_disposed) {
        _fx.burst(_lastSize);
        _burst = true;
      }
    });
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_burst && _fx.step(dt.clamp(0.0, 1 / 30), _lastSize)) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight.isFinite) {
          _lastSize = Size(constraints.maxWidth, constraints.maxHeight);
        }
        return Stack(
          children: [
            // Roasted-brown / cream surface, faint pattern + amber wash.
            Positioned.fill(child: _Surface(palette: p)),
            // Warm glow pool blooming behind the banner.
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              child: Center(child: _GlowPool(palette: p)),
            ),
            // Banner + leaderboard + actions.
            Positioned.fill(child: _Content(data: widget.data, palette: p)),
            // Confetti, above the content.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ConfettiPainter(_fx, repaint: _frame),
                  ),
                ),
              ),
            ),
            // Close control.
            PositionedDirectional(
              top: 12,
              end: 12,
              child: ZaadCircleIconButton.close(
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Surface ────────────────────────────────────────────────────────────────

class _Surface extends StatelessWidget {
  const _Surface({required this.palette});

  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.surfaceTop, p.surfaceBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/islamic-pattern.png',
              repeat: ImageRepeat.repeat,
              alignment: Alignment.topLeft,
              color: p.ink,
              colorBlendMode: BlendMode.screen,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.92),
                radius: 0.95,
                colors: [
                  p.accent.withValues(alpha: 0.16),
                  p.accent.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.62],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glow pool ──────────────────────────────────────────────────────────────

class _GlowPool extends StatefulWidget {
  const _GlowPool({required this.palette});

  final _CelPalette palette;

  @override
  State<_GlowPool> createState() => _GlowPoolState();
}

class _GlowPoolState extends State<_GlowPool>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
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
        final pulse = 1 + 0.07 * Curves.easeInOut.transform(_pulse.value);
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  p.accent.withValues(alpha: 0.45 * p.glowOpacity),
                  p.glow.withValues(alpha: 0.16 * p.glowOpacity),
                  p.glow.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.52, 0.72],
              ),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms, curve: _ease)
        .scaleXY(begin: 0.5, end: 1, delay: 300.ms, duration: 700.ms, curve: _ease);
  }
}

// ─── Content (banner + leaderboard + actions) ────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.data, required this.palette});

  final TeamNumberOneCelebrationDialog data;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        _tag(),
        const SizedBox(height: 12),
        _title(),
        const SizedBox(height: 6),
        _arabic(),
        const SizedBox(height: 12),
        _subtitle(),
        const SizedBox(height: 22),
        _board(),
        const SizedBox(height: 20),
        _actions(context),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      physics: const ClampingScrollPhysics(),
      child: column,
    );
  }

  Widget _tag() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: palette.ember.withValues(alpha: 0.16),
          border: Border.all(color: palette.emberLight.withValues(alpha: 0.42)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniCrown(color: palette.emberLight, size: 11),
            const SizedBox(width: 6),
            Text(
              'teams.number_one.eyebrow'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: palette.emberLight,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1000.ms,
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
          'teams.number_one.title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 0.98,
            letterSpacing: -1.1,
            color: Colors.white,
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 1100.ms, duration: 700.ms, curve: _ease)
          .scaleXY(
            begin: 0.94,
            end: 1,
            delay: 1100.ms,
            duration: 700.ms,
            curve: Curves.easeOutBack,
          )
          .moveY(begin: 14, end: 0, delay: 1100.ms, duration: 700.ms, curve: _ease);

  Widget _arabic() => Text(
        'teams.number_one.arabic'.tr(),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: palette.accent,
          height: 1.2,
        ),
      ).animate().fadeIn(delay: 1300.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1300.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _subtitle() => DefaultTextStyle(
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: palette.muted,
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
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' ${'teams.number_one.subtitle_suffix'.tr(namedArgs: {
                        'count': '${data.companions}',
                      })}',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ).animate().fadeIn(delay: 1450.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 10,
            end: 0,
            delay: 1450.ms,
            duration: 600.ms,
            curve: _ease,
          );

  Widget _board() => Column(
        children: [
          for (var i = 0; i < data.entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LeaderRow(entry: data.entries[i], palette: palette)
                .animate()
                .fadeIn(
                  delay: (1500 + i * 90).ms,
                  duration: 500.ms,
                  curve: _ease,
                )
                .moveY(
                  begin: 12,
                  end: 0,
                  delay: (1500 + i * 90).ms,
                  duration: 500.ms,
                  curve: _ease,
                ),
          ],
        ],
      );

  Widget _actions(BuildContext context) => Column(
        children: [
          _GoldButton(
            label: 'teams.number_one.share_cta'.tr(),
            icon: Icons.ios_share_rounded,
            palette: palette,
            onTap: () =>
                (data.onShare ?? () => Navigator.of(context).maybePop())(),
          ),
          const SizedBox(height: 11),
          _GhostButton(
            label: 'teams.number_one.view_cta'.tr(),
            palette: palette,
            onTap: () => (data.onViewLeaderboard ??
                () => Navigator.of(context).maybePop())(),
          ),
        ],
      ).animate().fadeIn(delay: 1900.ms, duration: 600.ms, curve: _ease).moveY(
            begin: 16,
            end: 0,
            delay: 1900.ms,
            duration: 600.ms,
            curve: _ease,
          );
}

// ─── Leaderboard row ──────────────────────────────────────────────────────────

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.palette});

  final TeamLeaderEntry entry;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final me = entry.isMe;

    final decoration = me
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p.accent.withValues(alpha: 0.18),
                p.accent.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: p.glassBorder),
            boxShadow: [
              BoxShadow(
                color: p.glow.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: p.ink.withValues(alpha: 0.03),
            border: Border.all(color: p.hairline),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: decoration,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: me ? p.accentSoft : p.faint,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(seed: entry.name, me: me, palette: p),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (me) ...[
                      const SizedBox(width: 6),
                      _YouTag(palette: p),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'teams.number_one.row_meta'.tr(namedArgs: {
                    'accuracy': '${entry.accuracy}',
                    'streak': '${entry.streak}',
                  }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: p.muted, height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPoints(entry.points),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: me ? p.accentSoft : p.accent,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPoints(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.seed, required this.me, required this.palette});

  final String seed;
  final bool me;
  final _CelPalette palette;

  @override
  Widget build(BuildContext context) {
    final disc = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44),
          colors: [palette.accentSoft, palette.accentDeep],
        ),
      ),
      child: Text(
        seed.characters.first,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: palette.goldInk,
          height: 1,
        ),
      ),
    );

    if (!me) return disc;

    // The crown drops onto the leader's avatar.
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          disc,
          Positioned(
            top: -17,
            child: _MiniCrown(color: palette.crown, size: 22)
                .animate()
                .fadeIn(delay: 560.ms, duration: 220.ms)
                .scaleXY(
                  begin: 0.4,
                  end: 1,
                  delay: 560.ms,
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .moveY(
                  begin: -18,
                  end: 0,
                  delay: 560.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                )
                .rotate(
                  begin: -0.08,
                  end: 0,
                  delay: 560.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ],
      ),
    );
  }
}

class _YouTag extends StatelessWidget {
  const _YouTag({required this.palette});

  final _CelPalette palette;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: palette.accent.withValues(alpha: 0.2),
          border: Border.all(color: palette.accent.withValues(alpha: 0.4)),
        ),
        child: Text(
          'leaderboard.you_pill'.tr(),
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: palette.accentSoft,
          ),
        ),
      );
}

// ─── Crown glyph ──────────────────────────────────────────────────────────────

/// The eight-point crown from the design, painted from the prototype's path.
class _MiniCrown extends StatelessWidget {
  const _MiniCrown({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size * 22 / 34),
        painter: _CrownPainter(color),
      );
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Path authored on a 36×24 viewBox; scale to the requested size.
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

// ─── Buttons ──────────────────────────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final _CelPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
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
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.9,
                color: p.goldInk,
              ),
            ),
            const SizedBox(width: 9),
            Icon(icon, size: 15, color: p.goldInk),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final _CelPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: p.ink.withValues(alpha: 0.05),
          border: Border.all(color: p.glassBorder),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: p.ink,
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
    final cy = size.height * 0.22;
    for (var i = 0; i < 48; i++) {
      final ang = _rnd(0, math.pi * 2);
      final sp = _rnd(3, 8);
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
        decay: _rnd(0.006, 0.013),
        ribbon: _rng.nextDouble() < 0.7,
      ));
    }
    for (var i = 0; i < 18; i++) {
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
        decay: _rnd(0.004, 0.008),
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
