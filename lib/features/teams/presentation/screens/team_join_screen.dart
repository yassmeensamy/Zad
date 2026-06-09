import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/corner_flourishes.dart';
import '../widgets/gilded_cta.dart';
import '../widgets/gold_rule.dart';
import '../widgets/team_scaffold.dart';

/// Number of pin slots rendered by [Pinput] for the invite code.
const int _kInviteCodeLength = 8;

/// Join team — D1 (premium idle) / D3 (premium error).
///
/// One [Pinput]-driven invite-code field with `_kInviteCodeLength` slots,
/// auto-submitting on completion. Errors swap the companions emblem for
/// a closed-keyhole variant and reveal recovery chips.
class TeamJoinScreen extends StatefulWidget {
  const TeamJoinScreen({super.key, this.initialCode});

  /// Invite code carried in by a deep link (`/teams/join?code=...`). When a
  /// full code arrives the field is prefilled and the join auto-submits.
  final String? initialCode;

  @override
  State<TeamJoinScreen> createState() => _TeamJoinScreenState();
}

class _TeamJoinScreenState extends State<TeamJoinScreen> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: _normalizedInitialCode());
    // Auto-submit when a complete code was delivered by a deep link, after the
    // cubit is available in the tree.
    if (_isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleSubmit();
      });
    }
  }

  /// Sanitizes the deep-link code to the same A–Z/0–9 uppercase shape the
  /// field enforces, capped at [_kInviteCodeLength].
  String _normalizedInitialCode() {
    final raw = widget.initialCode;
    if (raw == null) return '';
    final cleaned = raw
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '');
    return cleaned.length > _kInviteCodeLength
        ? cleaned.substring(0, _kInviteCodeLength)
        : cleaned;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _isComplete => _codeController.text.length >= _kInviteCodeLength;

  void _handleSubmit() {
    if (!_isComplete) return;
    context.read<TeamsCubit>().joinTeam(joinCode: _codeController.text.trim());
  }

  void _handleCodeChanged() => setState(() {});

  void _handleTryAgain() {
    _codeController.clear();
    _clearError();
    setState(() {});
  }

  void _clearError() {
    final cubit = context.read<TeamsCubit>();
    if (cubit.state.joinStatus == JoinStatus.error) {
      cubit.resetJoinState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.joinStatus != b.joinStatus,
      listener: (context, state) {
        if (state.joinStatus == JoinStatus.success) {
          context.pushReplacementNamed(AppRoutes.teamJoinSuccessName);
        }
      },
      builder: (context, state) {
        final submitting = state.joinStatus == JoinStatus.submitting;
        final hasError = state.joinStatus == JoinStatus.error;

        return TeamScaffold(
          appBar: ZaadAppBar(
            title: 'teams.join.title',
            subtitle: 'teams.join.eyebrow',
            backgroundColor: Colors.transparent,
            onBack: submitting
                ? null
                : context.canPop()
                ? () => context.pop()
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    const _AmberWash(),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      child: hasError
                          ? _ErrorContent(
                              enteredCode: _codeController.text,
                              onTryAgain: _handleTryAgain,
                              onHelp: _clearError,
                            )
                          : _IdleContent(
                              controller: _codeController,
                              onChanged: _handleCodeChanged,
                              onCompleted: _handleSubmit,
                            ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: GildedCta(
                    label: submitting
                        ? 'teams.join.submitting'.tr()
                        : 'teams.join.cta'.tr(),
                    enabled: _isComplete && !submitting && !hasError,
                    loading: submitting,
                    onTap: _handleSubmit,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Soft amber wash behind the emblem ──────────────────────────────────────

class _AmberWash extends StatelessWidget {
  const _AmberWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: 1.6,
            heightFactor: 0.55,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x38E0A560), Color(0x00E0A560)],
                  stops: [0, 0.65],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Idle content (D1) ──────────────────────────────────────────────────────

class _IdleContent extends StatelessWidget {
  const _IdleContent({
    required this.controller,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const _OrnamentEyebrow(text: 'teams.join.find_circle'),
        const SizedBox(height: 18),
        const Center(child: _CompanionsEmblem(size: 140)),
        const SizedBox(height: 16),
        Center(
          child: ResponsiveText(
            'teams.join.lede_title',
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: colors.oliveDeep,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ResponsiveText(
              'teams.join.lede',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: colors.oliveSoft,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _PremiumInviteField(
          controller: controller,
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
        const SizedBox(height: 18),
        const _OrDivider(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ResponsiveText(
            'teams.join.deep_link_hint',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: colors.oliveSoft,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error content (D3) ─────────────────────────────────────────────────────

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.enteredCode,
    required this.onTryAgain,
    required this.onHelp,
  });

  final String enteredCode;
  final VoidCallback onTryAgain;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _ErrorCodeChip(code: enteredCode),
        const SizedBox(height: 28),
        const Center(child: _ClosedKeyholeEmblem(size: 104)),
        const SizedBox(height: 14),
        Center(
          child: ResponsiveText(
            'teams.join.error_title',
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.oliveDeep,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ResponsiveText(
              'teams.join.error_lede',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: colors.oliveSoft,
                height: 1.55,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const DotRule(),
        const SizedBox(height: 12),
        
      ],
    );
  }
}

// ─── Ornament eyebrow: gold-rule · text · gold-rule ─────────────────────────

class _OrnamentEyebrow extends StatelessWidget {
  const _OrnamentEyebrow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GoldRule(reversed: false, width: 38),
        const SizedBox(width: 12),
        ResponsiveText(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.4,
            color: colors.goldDeep,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),
        const GoldRule(reversed: true, width: 38),
      ],
    );
  }
}

// ─── Companions emblem — 8-point gold star with three figures ──────────────
//
// Used by D1 idle. The painted [_KeyholeEmblem] below is kept for the
// closed/error variant (D3) where the diagonal slash matters semantically.

class _CompanionsEmblem extends StatelessWidget {
  const _CompanionsEmblem({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final glow = context.appColors.goldMid.withValues(alpha: 0.32);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [glow, glow.withValues(alpha: 0)],
                stops: const [0, 0.7],
              ),
            ),
          ),
          Image.asset(
            AppImages.teamCompanionsEmblem,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ],
      ),
    );
  }
}

// ─── Closed-keyhole emblem (error variant only) ─────────────────────────────

class _ClosedKeyholeEmblem extends StatelessWidget {
  const _ClosedKeyholeEmblem({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final glow = colors.errRimDark.withValues(alpha: 0.16);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [glow, glow.withValues(alpha: 0)],
                stops: const [0, 0.7],
              ),
            ),
          ),
          SizedBox.expand(
            child: CustomPaint(
              painter: _ClosedKeyholePainter(
                rim: colors.errRimDark,
                disc: colors.errRose,
                slash: colors.errStroke,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedKeyholePainter extends CustomPainter {
  _ClosedKeyholePainter({
    required this.rim,
    required this.disc,
    required this.slash,
  });

  final Color rim;
  final Color disc;
  final Color slash;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Dashed outer orbit ring.
    _drawDashedCircle(
      canvas,
      c,
      r * 0.93,
      dashWidth: 1.5,
      gapWidth: 4,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = rim.withValues(alpha: 0.55),
    );

    // Two overlapping 8-point stars (rotated 45°), outline only.
    final starScale = r / 60;
    final starPath = _starPath(c, 46 * starScale, 9 * starScale, 0);
    final starPathRot =
        _starPath(c, 46 * starScale, 9 * starScale, math.pi / 4);
    canvas.drawPath(
      starPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeJoin = StrokeJoin.round
        ..color = rim.withValues(alpha: 0.7),
    );
    canvas.drawPath(
      starPathRot,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeJoin = StrokeJoin.round
        ..color = rim.withValues(alpha: 0.45),
    );

    // Inner disc.
    final discRadius = r * 0.36;
    canvas.drawCircle(
      c,
      discRadius,
      Paint()
        ..style = PaintingStyle.fill
        ..color = disc.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      c,
      discRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = rim,
    );

    // Keyhole glyph — circle head + tapered shaft.
    final glyph = Paint()..color = rim.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.05), r * 0.07, glyph);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.04, c.dy)
        ..lineTo(c.dx + r * 0.04, c.dy)
        ..lineTo(c.dx + r * 0.027, c.dy + r * 0.15)
        ..lineTo(c.dx - r * 0.027, c.dy + r * 0.15)
        ..close(),
      glyph,
    );

    // Diagonal slash.
    canvas.drawLine(
      Offset(c.dx - r * 0.3, c.dy + r * 0.3),
      Offset(c.dx + r * 0.3, c.dy - r * 0.3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = slash,
    );
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius, {
    required double dashWidth,
    required double gapWidth,
    required Paint paint,
  }) {
    final circumference = 2 * math.pi * radius;
    final dashCount = circumference ~/ (dashWidth + gapWidth);
    final segment = (dashWidth + gapWidth) / radius;
    final dashAngle = dashWidth / radius;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segment,
        dashAngle,
        false,
        paint,
      );
    }
  }

  Path _starPath(Offset c, double r, double rIn, double rotation) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final angle = rotation - math.pi / 2 + i * math.pi / 8;
      final radius = i.isEven ? r : rIn;
      final p = Offset(
        c.dx + math.cos(angle) * radius,
        c.dy + math.sin(angle) * radius,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _ClosedKeyholePainter oldDelegate) => false;
}

// ─── Invite-code field — Pinput, themed to the manuscript palette ──────────

class _PremiumInviteField extends StatelessWidget {
  const _PremiumInviteField({
    required this.controller,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final defaultTheme = PinTheme(
      width: 34,
      height: 44,
      textStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.oliveDeep,
        height: 1,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            colors.goldLight.withValues(alpha: 0.28),
          ],
        ),
        border: Border.all(
          color: colors.goldDeep.withValues(alpha: 0.28),
          width: 1.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: colors.goldDeep, width: 1.6),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: colors.goldDeep.withValues(alpha: 0.22),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final submittedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, colors.goldLight.withValues(alpha: 0.55)],
        ),
        border: Border.all(
          color: colors.goldDeep.withValues(alpha: 0.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.goldDeep.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ResponsiveText(
            'teams.join.code_label'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: colors.goldDeep,
              height: 1,
            ),
          ),
        ),
        Pinput(
          length: _kInviteCodeLength,
          controller: controller,
          defaultPinTheme: defaultTheme,
          focusedPinTheme: focusedTheme,
          submittedPinTheme: submittedTheme,
          // Uppercase A–Z + 0–9 only, applied at the formatter layer so
          // pasted lowercase/punctuation is normalized too.
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            _UpperCaseTextFormatter(),
          ],
          keyboardType: TextInputType.visiblePassword,
          autofocus: false,
          showCursor: true,
          cursor: Container(
            width: 1.6,
            height: 20,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: colors.goldDeep,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          separatorBuilder: (index) => index == (_kInviteCodeLength ~/ 2) - 1
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 10,
                    height: 1.8,
                    decoration: BoxDecoration(
                      color: colors.goldDeep.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              : const SizedBox(width: 6),
          onChanged: (_) => onChanged(),
          onCompleted: (_) => onCompleted(),
        ),
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}

// ─── "or" hairline divider ──────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final goldDeep = colors.goldDeep;
    final rule = Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            goldDeep.withValues(alpha: 0),
            goldDeep.withValues(alpha: 0.4),
            goldDeep.withValues(alpha: 0),
          ],
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: rule),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ResponsiveText(
            'teams.join.or'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
              color: colors.oliveSoft,
              height: 1,
            ),
          ),
        ),
        Expanded(child: rule),
      ],
    );
  }
}

// ─── Error code chip (D3 top strip) ─────────────────────────────────────────

class _ErrorCodeChip extends StatelessWidget {
  const _ErrorCodeChip({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shown =
        code.isEmpty ? List.filled(_kInviteCodeLength, '—').join(' ') : code;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          decoration: BoxDecoration(
            color: colors.errRose,
            border: Border.all(
              color: colors.errStroke.withValues(alpha: 0.5),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      '${'teams.join.code_label'.tr()} · '
                              '${'teams.join.error_title'.tr().replaceAll('.', '')}'
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.7,
                        color: colors.errStroke,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shown,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                        color: colors.errStroke.withValues(alpha: 0.85),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.errStroke,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        CornerFlourishes(color: colors.errStroke),
      ],
    );
  }
}

class _RecoveryChip extends StatelessWidget {
  const _RecoveryChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            border: Border.all(color: colors.olive.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: colors.oliveDeep),
              const SizedBox(width: 6),
              ResponsiveText(
                label.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: colors.oliveDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

