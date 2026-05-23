import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../widgets/create_team_sheet.dart';
import '../widgets/team_scaffold.dart';

/// Empty state — two doors, equal weight: Create or Join.
class TeamEmptyScreen extends StatelessWidget {
  const TeamEmptyScreen({super.key});

  Future<void> _onCreate(BuildContext context) async {
    final created = await showCreateTeamSheet(context);
    if (created && context.mounted) {
      // Route to the celebration screen — invite code chip + 'Enter team
      // home' CTA. From there the user lands on /teams/home.
      context.goNamed(AppRoutes.teamCreateSuccessName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TeamScaffold(
      appBar: ZaadAppBar(
        title: 'teams.empty.title',
        subtitle: 'teams.empty.eyebrow',
        backgroundColor: Colors.transparent,
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          children: [
            const Spacer(),
            const _EmptyIllus(),
            const SizedBox(height: 28),
            ResponsiveText(
              'teams.empty.title_lede',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 22,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              'teams.empty.hadith_ar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: colors.textArabic,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ResponsiveText(
                'teams.empty.lede',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  color: colors.oliveSoft,
                  height: 1.55,
                ),
              ),
            ),
            const Spacer(flex: 2),
            CustomButton.full(
              onTap: () => _onCreate(context),
              theme: CustomButtonTheme(
                height: 52,
                useGradient: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.oliveSoft, colors.olive, colors.oliveDeep],
                ),
                borderRadius: ZaadRadii.lg,
                textColor: colors.canvas,
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.canvas,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText(
                    'teams.empty.cta_create'.tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.canvas,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.add_rounded, size: 18, color: colors.canvas),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomButton.full(
              onTap: () => context.pushNamed(AppRoutes.teamJoinName),
              theme: CustomButtonTheme(
                height: 48,
                backgroundColor: colors.canvas.withValues(alpha: 0.45),
                borderColor: colors.olive,
                borderRadius: ZaadRadii.lg,
                textColor: colors.oliveDeep,
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: colors.oliveDeep,
                ),
              ),
              child: ResponsiveText(
                'teams.empty.cta_join'.tr().toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: colors.oliveDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium animated illustration — breathing halo + counter-rotating dashed
/// rings + orbiting sparks around a softly pulsing emblem.
class _EmptyIllus extends StatelessWidget {
  const _EmptyIllus();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const size = 200.0;

    return SizedBox(
      width: size,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing radial halo behind the emblem.
          RepaintBoundary(
            child: SizedBox(width: size + 20, height: size + 20)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 4200.ms,
                  curve: Curves.easeInOut,
                  builder: (_, t, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accent.withValues(
                            alpha: 0.06 + 0.12 * t,
                          ),
                          colors.accent.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
          ),

          // Outer dashed orbit + four orbiting sparks, driven by a single
          // ticker so the ring and sparks stay locked together.
          RepaintBoundary(
            child: const SizedBox(width: size, height: size)
                .animate(onPlay: (c) => c.repeat())
                .custom(
                  duration: 28.seconds,
                  builder: (_, t, _) => CustomPaint(
                    size: const Size.square(size),
                    painter: _OuterOrbitPainter(
                      t: t,
                      ringColor: colors.oliveLeaf.withValues(alpha: 0.55),
                      sparkColor: colors.accent,
                      sparkHaloColor: colors.accent.withValues(alpha: 0.35),
                    ),
                  ),
                ),
          ),

          // Inner dashed orbit — clockwise, tighter dashes.
          RepaintBoundary(
            child: CustomPaint(
              size: const Size.square(size - 56),
              painter: _DashedRingPainter(
                color: colors.accentDeep.withValues(alpha: 0.45),
                strokeWidth: 1.4,
                dash: 3,
                gap: 6,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(begin: 0, end: 1, duration: 18.seconds),
          ),

          // Center emblem — gently breathing scale + soft glow shadow.
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.canvas, AppColors.sand],
              ),
              border: Border.all(color: colors.accentDeep, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: -6,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.groups_2_outlined,
              color: colors.oliveDeep,
              size: 38,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.96,
                end: 1.04,
                duration: 2600.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

/// Paints a dashed circle inscribed in the given size.
class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    final segment = dash + gap;
    final count = (circumference / segment).floor();
    final step = 2 * math.pi / count;
    final dashAngle = (dash / circumference) * 2 * math.pi;

    for (var i = 0; i < count; i++) {
      final start = i * step;
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          dashAngle,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}

/// Paints the outer dashed orbit (counter-clockwise) together with the four
/// sparks orbiting clockwise on the same circle. Both are driven by the same
/// `t` so they share one ticker and never drift.
class _OuterOrbitPainter extends CustomPainter {
  const _OuterOrbitPainter({
    required this.t,
    required this.ringColor,
    required this.sparkColor,
    required this.sparkHaloColor,
  });

  /// 0..1 progress; multiplied into 2π for the orbit angle.
  final double t;
  final Color ringColor;
  final Color sparkColor;
  final Color sparkHaloColor;

  static const double _strokeWidth = 1.4;
  static const double _dash = 6;
  static const double _gap = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = math.min(size.width, size.height) / 2 - _strokeWidth;
    final ringRect = Rect.fromCircle(center: center, radius: ringRadius);

    // Counter-clockwise dashed ring.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-t * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    final circumference = 2 * math.pi * ringRadius;
    const segment = _dash + _gap;
    final count = (circumference / segment).floor();
    final step = 2 * math.pi / count;
    final dashAngle = (_dash / circumference) * 2 * math.pi;
    for (var i = 0; i < count; i++) {
      canvas.drawPath(
        Path()..addArc(ringRect, i * step, dashAngle),
        ringPaint,
      );
    }
    canvas.restore();

    // Clockwise sparks on the inscribed circle.
    final sparkRadius = math.min(size.width, size.height) / 2 - 2;
    final base = t * 2 * math.pi;
    final core = Paint()..color = sparkColor;
    final halo = Paint()
      ..color = sparkHaloColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (var i = 0; i < 4; i++) {
      final angle = base + i * (math.pi / 2);
      final dot = Offset(
        center.dx + sparkRadius * math.cos(angle),
        center.dy + sparkRadius * math.sin(angle),
      );
      canvas.drawCircle(dot, 5, halo);
      canvas.drawCircle(dot, 2.4, core);
    }
  }

  @override
  bool shouldRepaint(covariant _OuterOrbitPainter old) =>
      old.t != t ||
      old.ringColor != ringColor ||
      old.sparkColor != sparkColor ||
      old.sparkHaloColor != sparkHaloColor;
}
