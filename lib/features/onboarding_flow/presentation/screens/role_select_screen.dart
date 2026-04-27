import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../splash/widgets/desert_background.dart';
import '../widgets/onboarding_topnav.dart';

enum _Role { individual, parent }

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  _Role? _selected;

  void _proceed() {
    if (_selected == null) return;
    if (_selected == _Role.parent) {
      context.go(AppRoutes.createProfiles);
    } else {
      context.go(AppRoutes.profileSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: DesertBackground(
        child: SafeArea(
          child: Column(
            children: [
              OnboardingTopNav(
                onBack: () => context.go(AppRoutes.login),
                showBrand: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                  child: Column(
                    children: [
                      _Heading(colors: colors),
                      const SizedBox(height: 28),
                      Expanded(
                        child: Column(
                          children: [
                            _RoleCard(
                              icon: Icons.person_outline_rounded,
                              label: 'role_select.individual_label'.tr(),
                              desc: 'role_select.individual_desc'.tr(),
                              selected: _selected == _Role.individual,
                              onTap: () =>
                                  setState(() => _selected = _Role.individual),
                            ),
                            const SizedBox(height: 14),
                            _RoleCard(
                              icon: Icons.family_restroom_rounded,
                              label: 'role_select.family_label'.tr(),
                              desc: 'role_select.family_desc'.tr(),
                              selected: _selected == _Role.parent,
                              onTap: () =>
                                  setState(() => _selected = _Role.parent),
                            ),
                          ],
                        ),
                      ),
                      AuthPrimaryButton(
                        label: 'common.continue',
                        onTap: _proceed,
                        enabled: _selected != null,
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: colors.textArabic.withValues(alpha: 0.55),
                          ),
                          children: [
                            TextSpan(text: 'role_select.footer_prefix'.tr()),
                            TextSpan(
                              text: 'role_select.footer_settings'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colors.oliveDeep,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveText(
          'role_select.eyebrow'.tr().toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 10 * 0.32,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: GoogleFonts.fraunces(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              height: 1.15,
              letterSpacing: -0.4,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'role_select.title_prefix'.tr()),
              TextSpan(
                text: 'role_select.title_accent'.tr(),
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.textArabic,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'role_select.subtitle',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(92, 22, 22, 22),
            constraints: const BoxConstraints(minHeight: 128),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: selected ? 0.85 : 0.55),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? colors.olive
                    : colors.oliveSoft.withValues(alpha: 0.22),
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.oliveDeep.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 18),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -70,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.ivory, AppColors.dune],
                        ),
                        border: Border.all(
                          color: colors.oliveSoft.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(icon, size: 26, color: colors.oliveDeep),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText(
                      label,
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.3,
                        height: 1,
                        color: colors.oliveDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ResponsiveText(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.dateSoft,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: selected ? colors.olive : colors.oliveSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
