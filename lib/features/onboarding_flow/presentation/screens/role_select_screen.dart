import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../widgets/onboarding_topnav.dart';
import '../widgets/role_card.dart';

typedef _RoleOption = ({
  IconData icon,
  String labelKey,
  String descKey,
  String route,
});

const List<_RoleOption> _roleOptions = [
  (
    icon: Icons.person_outline_rounded,
    labelKey: 'role_select.individual_label',
    descKey: 'role_select.individual_desc',
    route: AppRoutes.home,
  ),
  (
    icon: Icons.family_restroom_rounded,
    labelKey: 'role_select.family_label',
    descKey: 'role_select.family_desc',
    route: AppRoutes.createProfiles,
  ),
];

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final ValueNotifier<_RoleOption?> _selected = ValueNotifier(null);

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _proceed() {
    final option = _selected.value;
    if (option == null) return;
    context.go(option.route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OnboardingTopNav(showBrand: true),
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
                          for (final option in _roleOptions) ...[
                            if (option != _roleOptions.first)
                              const SizedBox(height: 14),
                            ValueListenableBuilder<_RoleOption?>(
                              valueListenable: _selected,
                              builder: (context, selected, _) => RoleCard(
                                icon: option.icon,
                                label: option.labelKey.tr(),
                                desc: option.descKey.tr(),
                                selected: selected == option,
                                onTap: () => _selected.value = option,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ValueListenableBuilder<_RoleOption?>(
                      valueListenable: _selected,
                      builder: (context, selected, _) => AuthPrimaryButton(
                        label: 'common.continue',
                        onTap: _proceed,
                        enabled: selected != null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: colors.textArabic.withValues(alpha: 0.55),
                        ),
                        children: [
                          TextSpan(text: 'role_select.footer_prefix'.tr()),
                          TextSpan(
                            text: 'role_select.footer_settings'.tr(),
                            style: AppTextStyles.labelLarge.copyWith(
                              letterSpacing: 0,
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
          style: ZaadType.eyebrow.copyWith(color: colors.oliveSoft),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: ZaadType.titleHero.copyWith(color: colors.oliveDeep),
            children: [
              TextSpan(text: 'role_select.title_prefix'.tr()),
              TextSpan(
                text: 'role_select.title_accent'.tr(),
                style: AppTextStyles.headlineMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colors.textArabic,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ResponsiveText(
          'role_select.subtitle',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: AppColors.dateSoft,
          ),
        ),
      ],
    );
  }
}

