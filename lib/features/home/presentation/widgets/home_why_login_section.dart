import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class HomeWhyLoginSection extends StatelessWidget {
  const HomeWhyLoginSection({super.key});

  static const _benefits = <(IconData, String, String)>[
    (
      Icons.local_fire_department_rounded,
      'home.why_login.benefits.streak_title',
      'home.why_login.benefits.streak_subtitle',
    ),
    (
      Icons.groups_rounded,
      'home.why_login.benefits.teams_title',
      'home.why_login.benefits.teams_subtitle',
    ),
    (
      Icons.workspace_premium_rounded,
      'home.why_login.benefits.ranks_title',
      'home.why_login.benefits.ranks_subtitle',
    ),
    (
      Icons.devices_rounded,
      'home.why_login.benefits.sync_title',
      'home.why_login.benefits.sync_subtitle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(22);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.cardSurface,
            colors.cardSurface.withValues(alpha: colors.cardSurface.a * 0.4),
          ],
        ),
        border: Border.all(color: colors.accent.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(1, -1),
                    radius: 1.1,
                    colors: [
                      colors.ctaMid.withValues(alpha: 0.28),
                      colors.ctaMid.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-1, -0.6),
                    radius: 1.0,
                    colors: [
                      colors.accent.withValues(alpha: 0.20),
                      colors.accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset(
                    AppImages.islamicPattern,
                    repeat: ImageRepeat.repeat,
                    color: colors.accent,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(colors: colors),
                  const SizedBox(height: 15),
                  for (final (icon, titleKey, subtitleKey) in _benefits) ...[
                    _BenefitRow(
                      icon: icon,
                      titleKey: titleKey,
                      subtitleKey: subtitleKey,
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  _CreateAccountButton(colors: colors),
                  const SizedBox(height: 11),
                  _SignInRow(colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});

  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: RadialGradient(
              center: const Alignment(-0.36, -0.44),
              radius: 0.9,
              colors: [colors.accentSoft, colors.accent, colors.accentDeep],
              stops: const [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.auto_awesome_rounded, size: 22, color: colors.goldInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: colors.ctaTop,
                  ),
                  const SizedBox(width: 5),
                  ResponsiveText(
                    'home.why_login.guest_tag',
                    style: ZaadType.fieldLabel.copyWith(
                      color: colors.ctaTop,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ResponsiveText(
                'home.why_login.title',
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 21,
                  height: 1.05,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.colors,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: colors.overlayLight,
            border: Border.all(color: colors.accent.withValues(alpha: 0.20)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: colors.accent),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                titleKey,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: 0,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              ResponsiveText(
                subtitleKey,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  height: 1.3,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.check_rounded, size: 16, color: colors.success),
      ],
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.colors});

  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goNamed(AppRoutes.signupName),
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.accentSoft, colors.accent, colors.accentDeep],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(ZaadRadii.lg),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ResponsiveText(
                    'home.why_login.cta',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: colors.goldInk,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Icon(Icons.arrow_forward_rounded, size: 16, color: colors.goldInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow({required this.colors});

  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(AppRoutes.loginName),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'home.why_login.have_account'.tr(),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: colors.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'home.why_login.sign_in'.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
