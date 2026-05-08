import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../child/presentation/cubit/child_cubit.dart';
import '../../../child/presentation/cubit/child_state.dart';
import '../widgets/onboarding_topnav.dart';
import '../widgets/role_card.dart';

enum _RoleKind { individual, family }

typedef _RoleOption = ({
  IconData icon,
  String labelKey,
  String descKey,
  _RoleKind kind,
});

const List<_RoleOption> _roleOptions = [
  (
    icon: Icons.person_outline_rounded,
    labelKey: 'role_select.individual_label',
    descKey: 'role_select.individual_desc',
    kind: _RoleKind.individual,
  ),
  (
    icon: Icons.family_restroom_rounded,
    labelKey: 'role_select.family_label',
    descKey: 'role_select.family_desc',
    kind: _RoleKind.family,
  ),
];

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChildCubit>(
      create: (_) => sl<ChildCubit>(),
      child: const _RoleSelectView(),
    );
  }
}

class _RoleSelectView extends StatefulWidget {
  const _RoleSelectView();

  @override
  State<_RoleSelectView> createState() => _RoleSelectViewState();
}

class _RoleSelectViewState extends State<_RoleSelectView> {
  final ValueNotifier<_RoleOption?> _selected = ValueNotifier(null);
  bool _resolving = false;

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _onSelect(_RoleOption option) {
    _selected.value = option;
    // Pre-fetch the children list as soon as the user shows family intent so
    // the routing decision on continue is usually instant.
    if (option.kind == _RoleKind.family) {
      final cubit = context.read<ChildCubit>();
      if (cubit.state.isInitial || cubit.state.isError) {
        cubit.fetchChildren();
      }
    }
  }

  Future<void> _proceed() async {
    final option = _selected.value;
    if (option == null || _resolving) return;

    if (option.kind == _RoleKind.individual) {
      context.go(AppRoutes.home);
      return;
    }

    final cubit = context.read<ChildCubit>();
    if (!cubit.state.isLoaded) {
      setState(() => _resolving = true);
      await cubit.fetchChildren();
      if (!mounted) return;
      setState(() => _resolving = false);
    }

    final destination = cubit.state.children.isEmpty
        ? AppRoutes.createProfiles
        : AppRoutes.profileSelect;
    context.go(destination);
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
                                onTap: () => _onSelect(option),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    BlocBuilder<ChildCubit, ChildState>(
                      buildWhen: (a, b) => a.status != b.status,
                      builder: (context, childState) {
                        return ValueListenableBuilder<_RoleOption?>(
                          valueListenable: _selected,
                          builder: (context, selected, _) {
                            final familyLoading =
                                selected?.kind == _RoleKind.family &&
                                    (_resolving || childState.isLoading);
                            return AuthPrimaryButton(
                              label: 'common.continue',
                              onTap: _proceed,
                              enabled: selected != null && !familyLoading,
                              loading: familyLoading,
                            );
                          },
                        );
                      },
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
