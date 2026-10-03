import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/accent_rich_title.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../onboarding_flow/presentation/widgets/onboarding_topnav.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_draft_cubit.dart';
import '../cubit/child_draft_state.dart';
import '../cubit/child_state.dart';
import '../widgets/kid_card.dart';

/// Reached from two places, so where "back" goes is an input rather than a
/// constant: role-select drives the first-run family setup, and profile-select's
/// "add another person" tile opens the same screen for an established parent.
/// Both arrive via `context.go`, which replaces the stack — there is nothing to
/// pop, so the screen has to be told which route it is returning to.
class CreateChildrenScreen extends StatelessWidget {
  const CreateChildrenScreen({super.key, this.backDestination});

  /// Route the back button and the OS back gesture return to. Defaults to
  /// role-select, the first-run entry point.
  final String? backDestination;

  void _onContinue(BuildContext context) => context.go(AppRoutes.profileSelect);

  void _onBack(BuildContext context) =>
      context.go(backDestination ?? AppRoutes.roleSelect);

  Future<void> _onSubmit(BuildContext context) async {
    final draftCubit = context.read<ChildDraftCubit>();
    final childCubit = context.read<ChildCubit>();

    final named = draftCubit.state.namedDrafts;
    if (named.isEmpty) {
      _onContinue(context);
      return;
    }
    if (named.any((d) => d.password.isEmpty)) {
      SnackBarHelper.showError(
        context,
        message: 'create_profiles.password_required_for_all',
      );
      return;
    }

    final payload = [
      for (final d in named)
        (
          username: d.name.trim(),
          fullName: d.name.trim(),
          password: d.password,
          birthDate: d.inferredBirthDate,
        ),
    ];
    await childCubit.createChildren(payload);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChildCubit>(create: (_) => sl<ChildCubit>()),
        BlocProvider<ChildDraftCubit>(
          create: (_) => sl<ChildDraftCubit>()..init(),
        ),
      ],
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final colors = context.appColors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack(context);
      },
      child: AppScaffold(
        body: SafeArea(
          child: BlocListener<ChildCubit, ChildState>(
            listenWhen: (a, b) => a.actionStatus != b.actionStatus,
            listener: (context, state) {
              if (state.isActionLoaded) {
                context.read<ChildCubit>().resetActionStatus();
                context.read<ChildDraftCubit>().clear();
                _onContinue(context);
              } else if (state.isActionError &&
                  state.actionErrorMessage != null) {
                SnackBarHelper.showError(
                  context,
                  message: state.actionErrorMessage!,
                );
              }
            },
            child: Column(
              children: [
                OnboardingTopNav(
                  onBack: () => _onBack(context),
                  stepLabel: 'create_profiles.step'.tr(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      children: [
                        _Heading(colors: colors),
                        const SizedBox(height: 18),
                        const Expanded(child: _DraftList()),
                        const SizedBox(height: 12),
                        BlocBuilder<ChildCubit, ChildState>(
                          buildWhen: (a, b) => a.actionStatus != b.actionStatus,
                          builder: (context, state) => AuthPrimaryButton(
                            label: 'common.continue',
                            loading: state.isActionLoading,
                            onTap: () => _onSubmit(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _onContinue(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: ResponsiveText(
                              'create_profiles.skip',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.dateSoft,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _DraftList extends StatelessWidget {
  const _DraftList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildDraftCubit, ChildDraftState>(
      buildWhen: _structuralChange,
      builder: (context, state) {
        final drafts = state.drafts;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: drafts.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == drafts.length) {
              return _AddKidTile(
                onTap: () => context.read<ChildDraftCubit>().add(),
              );
            }
            final draft = drafts[i];
            return KidCard(
              key: ValueKey(draft.id),
              draft: draft,
              showRemove: drafts.length > 1,
            );
          },
        );
      },
    );
  }

  static bool _structuralChange(ChildDraftState a, ChildDraftState b) {
    if (a.drafts.length != b.drafts.length) return true;
    for (var i = 0; i < a.drafts.length; i++) {
      final pa = a.drafts[i];
      final pb = b.drafts[i];
      if (pa.id != pb.id) return true;
      if (pa.avatar != pb.avatar) return true;
      if (pa.password.isEmpty != pb.password.isEmpty) return true;
    }
    return false;
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
          'create_profiles.eyebrow'.tr().toUpperCase(),
          style: ZaadType.eyebrow.copyWith(color: colors.oliveSoft),
        ),
        const SizedBox(height: 10),
        AccentRichTitle(
          prefixKey: 'create_profiles.title_prefix',
          accentKey: 'create_profiles.title_accent',
          baseStyle: ZaadType.titleHero.copyWith(
            fontSize: 28,
            color: colors.oliveDeep,
          ),
          accentStyle: AppTextStyles.displayMedium.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: colors.textArabic,
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'create_profiles.subtitle',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              height: 1.5,
              color: colors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddKidTile extends StatelessWidget {
  const _AddKidTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZaadRadii.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ZaadRadii.xl),
            border: Border.all(
              color: colors.oliveSoft.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 16, color: colors.olive),
              const SizedBox(width: 8),
              ResponsiveText(
                'create_profiles.add_child',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 12.5 * 0.18,
                  color: colors.olive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
