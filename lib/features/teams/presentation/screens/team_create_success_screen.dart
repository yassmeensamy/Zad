import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/deep_links.dart';
import '../../../../theme/theme.dart';
import '../../data/models/team_model.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/corner_flourishes.dart';
import '../widgets/gilded_cta.dart';
import '../widgets/team_scaffold.dart';

/// Decree palette — illuminated-manuscript golds, parchment surfaces and
/// brown inks for the create-success celebration. All colors live in
/// [AppColorsTheme] so the Decree and Join Team screens share one source
/// of truth.

class TeamCreateSuccessScreen extends StatefulWidget {
  const TeamCreateSuccessScreen({super.key});

  @override
  State<TeamCreateSuccessScreen> createState() =>
      _TeamCreateSuccessScreenState();
}

class _TeamCreateSuccessScreenState extends State<TeamCreateSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Defensive: shouldn't happen because we only push this after success,
    // but if state got reset (cold restart) just bounce home — once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = context.read<TeamsCubit>().state;
      if (s.createdTeam == null && s.team == null) {
        context.goNamed(AppRoutes.teamHomeName);
      }
    });
  }

  void _goHome() => context.goNamed(AppRoutes.teamHomeName);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TeamsCubit, TeamsState, TeamModel?>(
      selector: (s) => s.createdTeam ?? s.team,
      builder: (context, team) {
        if (team == null) return const TeamScaffold(child: SizedBox.shrink());
        return _DecreeScaffold(
          child: _DecreeBody(team: team, onHome: _goHome, onClose: _goHome),
        );
      },
    );
  }
}

/// Replaces the default TeamScaffold gradient for the Decree screen with the
/// brighter parchment gradient the design calls for.
class _DecreeScaffold extends StatelessWidget {
  const _DecreeScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.parchmentTop,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.parchmentTop, colors.parchmentBottom],
          ),
        ),
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}

class _DecreeBody extends StatelessWidget {
  const _DecreeBody({
    required this.team,
    required this.onHome,
    required this.onClose,
  });

  final TeamModel team;
  final VoidCallback onHome;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            const Positioned.fill(child: _PatternOverlay()),
            const _EmberField(),
            Positioned(
              top: 8,
              right: 14,
              child: _CloseButton(onTap: onClose),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Eyebrow(),
                  const SizedBox(height: 14),
                  Center(child: _Medallion(seed: team.name)),
                  const SizedBox(height: 10),
                  _CopyBlock(teamName: team.name),
                  const SizedBox(height: 22),
                  _GildedInviteChip(code: team.joinCode),
                  const Spacer(),
                  _AnimatedGildedCta(onTap: onHome),
                  const SizedBox(height: 12),
                  _GhostButton(onTap: onHome),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Pattern overlay ────────────────────────────────────────────────────────

class _PatternOverlay extends StatelessWidget {
  const _PatternOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.08,
        child: Image.asset(
          'assets/images/islamic-pattern.png',
          repeat: ImageRepeat.repeat,
          fit: BoxFit.none,
          alignment: Alignment.topCenter,
          colorBlendMode: BlendMode.multiply,
          color: const Color(0xFF8B6A2C),
        ),
      ),
    );
  }
}

// ─── Close button ───────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.55),
            border: Border.all(color: colors.goldDeep.withValues(alpha: 0.35)),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: colors.inkBrownDeep,
          ),
        ),
      ),
    );
  }
}

// ─── Eyebrow: rule — text — rule ────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    final text = Text(
      'teams.create.success_eyebrow'.tr(),
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2,
        color: goldDeep,
        height: 1,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 700.ms);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _EyebrowRule(reversed: false, delay: 250.ms),
        const SizedBox(width: 10),
        text,
        const SizedBox(width: 10),
        _EyebrowRule(reversed: true, delay: 300.ms),
      ],
    );
  }
}

class _EyebrowRule extends StatelessWidget {
  const _EyebrowRule({required this.reversed, required this.delay});
  final bool reversed;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    final transparent = goldDeep.withValues(alpha: 0);
    final gradient = LinearGradient(
      colors: reversed ? [goldDeep, transparent] : [transparent, goldDeep],
    );
    return DecoratedBox(decoration: BoxDecoration(gradient: gradient))
        .animate()
        .custom(
          delay: delay,
          duration: 700.ms,
          curve: const Cubic(0.22, 0.8, 0.3, 1),
          builder: (_, t, _) =>
              SizedBox(width: 36 * t, height: 1, child: const _RuleFill()),
        );
  }
}

class _RuleFill extends StatelessWidget {
  const _RuleFill();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─── Medallion ──────────────────────────────────────────────────────────────

class _Medallion extends StatefulWidget {
  const _Medallion({required this.seed});
  final String seed;

  @override
  State<_Medallion> createState() => _MedallionState();
}

class _MedallionState extends State<_Medallion>
    with TickerProviderStateMixin {
  /// Slow forever-orbit on the dashed ring. 120 s for a full revolution —
  /// almost imperceptible, exactly as the design specifies.
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  String get _monogram {
    final t = widget.seed.trim();
    if (t.isEmpty) return '?';
    return t.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const size = 170.0;

    final medallion = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo — breathes forever via flutter_animate.
          RepaintBoundary(
            child:
                SizedBox(width: size + 44, height: size + 44)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .custom(
                      duration: 5500.ms,
                      curve: Curves.easeInOut,
                      builder: (_, t, _) => DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.lerp(
                                const Color(0x52E8B968),
                                const Color(0x8EE8B968),
                                t,
                              )!,
                              const Color(0x00E8B968),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
          ),

          // Rotating dashed orbit + static disc body (star, rings, inner disc).
          RepaintBoundary(
            child: CustomPaint(
              size: const Size.square(size),
              painter: _MedallionPainter(
                orbit: _orbit,
                goldLight: colors.goldLight,
                goldMid: colors.goldMid,
                goldDeep: colors.goldDeep,
                goldDark: colors.goldDark,
                inkBrownDeep: colors.inkBrownDeep,
              ),
            ),
          ),

          // Monogram — initial of the team name, gold-debossed.
          Text(
            _monogram,
            style: TextStyle(
              fontFamily: 'ElMessiri',
              fontWeight: FontWeight.w700,
              fontSize: 38,
              color: colors.inkBrown,
              height: 1,
              shadows: const [
                Shadow(
                  color: Color(0x66FFFFFF),
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),

          // Green seal — pops in after the medallion settles.
          Positioned(
            right: 14,
            bottom: 14,
            child:
                const _CheckSeal()
                    .animate()
                    .scaleXY(
                      delay: 1000.ms,
                      duration: 700.ms,
                      curve: const Cubic(0.5, 1.7, 0.5, 1),
                      begin: 0,
                      end: 1,
                    )
                    .rotate(
                      delay: 1000.ms,
                      duration: 700.ms,
                      curve: const Cubic(0.5, 1.7, 0.5, 1),
                      begin: -30 / 360,
                      end: 0,
                    ),
          ),
        ],
      ),
    );

    // Entrance: scale 0.55 → 1.0 with a tiny rotational settle, delayed 350 ms.
    return medallion
        .animate()
        .scaleXY(
          delay: 350.ms,
          duration: 1000.ms,
          curve: const Cubic(0.2, 1.2, 0.3, 1),
          begin: 0.55,
          end: 1,
        )
        .fadeIn(delay: 350.ms, duration: 400.ms)
        .rotate(
          delay: 350.ms,
          duration: 1000.ms,
          curve: const Cubic(0.2, 1.2, 0.3, 1),
          begin: -12 / 360,
          end: 0,
        );
  }
}

class _CheckSeal extends StatelessWidget {
  const _CheckSeal();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.sealGreen, colors.sealGreenDeep],
        ),
        border: Border.all(color: colors.parchmentTop, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x592A331C),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
    );
  }
}

class _MedallionPainter extends CustomPainter {
  _MedallionPainter({
    required this.orbit,
    required this.goldLight,
    required this.goldMid,
    required this.goldDeep,
    required this.goldDark,
    required this.inkBrownDeep,
  }) : super(repaint: orbit);

  /// Rotation of the dashed orbit ring (0..1 → 0..2π).
  final Animation<double> orbit;
  final Color goldLight;
  final Color goldMid;
  final Color goldDeep;
  final Color goldDark;
  final Color inkBrownDeep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Design viewBox is 0..200; we scale to size.shortestSide.
    final unit = size.shortestSide / 200.0;

    // ── slow-rotating dashed orbit (r=96) ────────────────────────────────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(orbit.value * 2 * math.pi);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9 * unit
      ..color = goldMid.withValues(alpha: 0.85);
    _paintDashedCircle(
      canvas,
      Offset.zero,
      96 * unit,
      dashLen: 2 * unit,
      gapLen: 6 * unit,
      paint: orbitPaint,
    );
    canvas.restore();

    // ── thin solid inner ring (r=80) ─────────────────────────────────────
    canvas.drawCircle(
      center,
      80 * unit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7 * unit
        ..color = goldMid.withValues(alpha: 0.6),
    );

    // ── 8-point star: two stretched 4-prong diamonds, second rotated 45° ─
    final starShader = RadialGradient(
      center: const Alignment(0, -0.24),
      radius: 0.6,
      colors: [goldLight, goldMid, goldDark],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: 72 * unit));

    // The star opacity in the design is 0.22 fill — soft, not loud.
    final fillSoft = Paint()
      ..style = PaintingStyle.fill
      ..shader = starShader
      ..color = const Color(0x38000000);
    final starStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * unit
      ..color = goldDeep;

    for (final rotation in [0.0, math.pi / 4]) {
      final path = _diamondPath(center, unit, rotation);
      canvas.drawPath(path, fillSoft);
      canvas.drawPath(path, starStroke);
    }

    // ── inner medallion disc (r=44) ──────────────────────────────────────
    final discRect = Rect.fromCircle(center: center, radius: 44 * unit);
    final discFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: const Alignment(0, -0.24),
        radius: 0.6,
        colors: [goldLight, goldMid, goldDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(discRect);
    canvas.drawCircle(center, 44 * unit, discFill);
    canvas.drawCircle(
      center,
      44 * unit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * unit
        ..color = inkBrownDeep,
    );
    // dashed inner highlight
    _paintDashedCircle(
      canvas,
      center,
      44 * unit,
      dashLen: 1 * unit,
      gapLen: 3 * unit,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * unit
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  Path _diamondPath(Offset center, double unit, double rotation) {
    // viewBox polygon: 0,-72  14,-14  72,0  14,14  0,72  -14,14  -72,0  -14,-14
    const pts = <Offset>[
      Offset(0, -72),
      Offset(14, -14),
      Offset(72, 0),
      Offset(14, 14),
      Offset(0, 72),
      Offset(-14, 14),
      Offset(-72, 0),
      Offset(-14, -14),
    ];
    final cos = math.cos(rotation);
    final sin = math.sin(rotation);
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      final x = (p.dx * cos - p.dy * sin) * unit;
      final y = (p.dx * sin + p.dy * cos) * unit;
      final dst = center + Offset(x, y);
      if (i == 0) {
        path.moveTo(dst.dx, dst.dy);
      } else {
        path.lineTo(dst.dx, dst.dy);
      }
    }
    return path..close();
  }

  void _paintDashedCircle(
    Canvas canvas,
    Offset center,
    double radius, {
    required double dashLen,
    required double gapLen,
    required Paint paint,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MedallionPainter old) =>
      old.orbit != orbit ||
      old.goldLight != goldLight ||
      old.goldMid != goldMid ||
      old.goldDeep != goldDeep ||
      old.goldDark != goldDark ||
      old.inkBrownDeep != inkBrownDeep;
}

// ─── Copy block ─────────────────────────────────────────────────────────────

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({required this.teamName});
  final String teamName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final arabic = _GradientText(
      text: 'teams.create.success_arabic'.tr(),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.amber,
          colors.goldDeep,
          colors.inkBrownDeep,
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
      style: const TextStyle(
        fontFamily: 'ElMessiri',
        fontWeight: FontWeight.w700,
        fontSize: 30,
        height: 1.0,
        shadows: [Shadow(color: Color(0x66FFFFFF), offset: Offset(0, 1))],
      ),
    );

    final name = Text(
      teamName,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'ElMessiri',
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: 22,
        height: 1.2,
        letterSpacing: -0.3,
        color: colors.oliveDeep,
      ),
    );

    final sub = Text(
      'teams.create.success_open'.tr(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'ElMessiri',
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: 13,
        color: colors.oliveSoft,
      ),
    );

    return Column(
      children: [
        arabic
            .animate()
            .fadeIn(delay: 1250.ms, duration: 800.ms)
            .moveY(
              delay: 1250.ms,
              duration: 800.ms,
              curve: const Cubic(0.22, 0.8, 0.3, 1),
              begin: 14,
              end: 0,
            ),
        const SizedBox(height: 10),
        name
            .animate()
            .fadeIn(delay: 1450.ms, duration: 700.ms)
            .moveY(
              delay: 1450.ms,
              duration: 700.ms,
              curve: const Cubic(0.22, 0.8, 0.3, 1),
              begin: 12,
              end: 0,
            ),
        const SizedBox(height: 3),
        sub
            .animate()
            .fadeIn(delay: 1600.ms, duration: 700.ms)
            .moveY(
              delay: 1600.ms,
              duration: 700.ms,
              curve: const Cubic(0.22, 0.8, 0.3, 1),
              begin: 10,
              end: 0,
            ),
        const SizedBox(height: 14),
        const _Hairline()
            .animate()
            .fadeIn(delay: 1750.ms, duration: 600.ms),
      ],
    );
  }
}

/// Gold-gradient text — wraps Text in a ShaderMask. Falls back to white text
/// so the gradient *replaces* the text fill.
class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => gradient.createShader(rect),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    final transparent = goldDeep.withValues(alpha: 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _HairlineRule(
          gradient: LinearGradient(colors: [transparent, goldDeep]),
          delay: 1800.ms,
        ),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: goldDeep,
          ),
        ),
        const SizedBox(width: 8),
        _HairlineRule(
          gradient: LinearGradient(colors: [goldDeep, transparent]),
          delay: 1800.ms,
        ),
      ],
    );
  }
}

class _HairlineRule extends StatelessWidget {
  const _HairlineRule({required this.gradient, required this.delay});
  final Gradient gradient;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: BoxDecoration(gradient: gradient))
        .animate()
        .custom(
          delay: delay,
          duration: 700.ms,
          curve: const Cubic(0.22, 0.8, 0.3, 1),
          builder: (_, t, _) => SizedBox(
            width: 40 * t,
            height: 1,
            child: const _RuleFill(),
          ),
        );
  }
}

// ─── Gilded invite chip ─────────────────────────────────────────────────────

class _GildedInviteChip extends StatelessWidget {
  const _GildedInviteChip({required this.code});
  final String code;

  Future<void> _share(BuildContext context) async {
    await sl<ShareService>().shareFrom(
      context: context,
      text: 'teams.create.share_message'.tr(
        namedArgs: {'code': code, 'link': DeepLinks.teamInvite(code)},
      ),
      subject: 'teams.create.share_subject'.tr(),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text('teams.create.copied'.tr()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final goldDeep = colors.goldDeep;

    final card = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: goldDeep.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: goldDeep.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'teams.create.success_invite_label'.tr().toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.8,
                        color: goldDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _GradientText(
                      text: code,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.amber, colors.textArabic],
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChipAction(
                icon: Icons.copy_rounded,
                onTap: () => _copy(context),
              ),
              const SizedBox(width: 6),
              _ChipAction(
                icon: Icons.ios_share_rounded,
                onTap: () => _share(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: goldDeep.withValues(alpha: 0.3)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 11,
                    color: colors.oliveSoft,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'teams.create.success_expires'.tr(),
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        color: colors.oliveSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Stack the four corner L-flourishes on top of the card, then animate the
    // entire group as the chip rises in.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        CornerFlourishes(color: goldDeep),
      ],
    )
        .animate()
        .fadeIn(delay: 1950.ms, duration: 900.ms)
        .moveY(
          delay: 1950.ms,
          duration: 900.ms,
          curve: const Cubic(0.22, 0.8, 0.3, 1),
          begin: 22,
          end: 0,
        )
        .scaleXY(
          delay: 1950.ms,
          duration: 900.ms,
          curve: const Cubic(0.22, 0.8, 0.3, 1),
          begin: 0.98,
          end: 1,
        );
  }
}

class _ChipAction extends StatelessWidget {
  const _ChipAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: goldDeep.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: goldDeep.withValues(alpha: 0.45)),
          ),
          child: Icon(icon, size: 14, color: goldDeep),
        ),
      ),
    );
  }
}

// ─── Gilded primary CTA + ghost button ──────────────────────────────────────

/// Decree-screen wrapper that adds the entrance animation around the shared
/// [GildedCta]. Kept private so the animation timings stay close to the
/// other Decree elements they're choreographed with.
class _AnimatedGildedCta extends StatelessWidget {
  const _AnimatedGildedCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GildedCta(
      label: 'teams.create.success_cta'.tr(),
      onTap: onTap,
    )
        .animate()
        .fadeIn(delay: 2200.ms, duration: 700.ms)
        .moveY(
          delay: 2200.ms,
          duration: 700.ms,
          begin: 10,
          end: 0,
        );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          TextButton(
            onPressed: onTap,
            child: Text(
              'teams.create.success_skip'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.3,
                color: context.appColors.oliveSoft,
              ),
            ),
          ).animate().fadeIn(delay: 2400.ms, duration: 600.ms),
    );
  }
}

// ─── Floating embers ────────────────────────────────────────────────────────

class _EmberField extends StatelessWidget {
  const _EmberField();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 180,
            child: _Ember(
              driftX: -22,
              driftY: -170,
              duration: 11000,
              delay: 2400,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 180,
            child: _Ember(
              driftX: 28,
              driftY: -185,
              duration: 13000,
              delay: 5500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Ember extends StatelessWidget {
  const _Ember({
    required this.driftX,
    required this.driftY,
    required this.duration,
    required this.delay,
  });

  final double driftX;
  final double driftY;
  final int duration;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.flameLight,
                      AppColors.flameGold,
                      Color(0x00F1C57A),
                    ],
                    stops: [0.0, 0.5, 0.8],
                  ),
                ),
              )
              .animate(
                onPlay: (c) => c.repeat(),
                delay: Duration(milliseconds: delay),
              )
              .custom(
                duration: Duration(milliseconds: duration),
                curve: Curves.easeOut,
                builder: (_, t, child) {
                  // 0..0.15 fade in to 0.55, 0.15..0.85 hold-fade to 0.25,
                  // 0.85..1 fade to 0 while drifting + scaling.
                  final opacity = t < 0.15
                      ? (t / 0.15) * 0.55
                      : t < 0.85
                            ? 0.55 - (t - 0.15) / 0.70 * 0.30
                            : 0.25 * (1 - (t - 0.85) / 0.15);
                  final scale = 0.4 + 0.8 * t;
                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(driftX * t, driftY * t),
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
              ),
    );
  }
}
