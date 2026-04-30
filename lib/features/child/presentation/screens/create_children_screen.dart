import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../onboarding_flow/presentation/widgets/onboarding_topnav.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_draft_cubit.dart';
import '../cubit/child_draft_state.dart';
import '../cubit/child_state.dart';
import '../widgets/kid_card.dart';

class CreateChildrenScreen extends StatelessWidget {
  const CreateChildrenScreen({super.key});

  void _onContinue(BuildContext context) => context.go(AppRoutes.profileSelect);

  Future<void> _onSubmit(BuildContext context) async {
    final draftCubit = context.read<ChildDraftCubit>();
    final childCubit = context.read<ChildCubit>();

    final named = draftCubit.state.namedDrafts;
    if (named.isEmpty) {
      _onContinue(context);
      return;
    }
    if (named.any((d) => d.password.isEmpty)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Please set a password for every child before continuing.',
            ),
          ),
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
      // Builder pushes a context that sits below the providers so
      // [context.read<...>()] resolves inside the same widget.
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
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
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.actionErrorMessage!)),
                );
            }
          },
          child: Column(
            children: [
              OnboardingTopNav(
                onBack: () => context.go(AppRoutes.roleSelect),
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
                        builder: (context, state) {
                          final loading = state.isActionLoading;
                          return AbsorbPointer(
                            absorbing: loading,
                            child: Opacity(
                              opacity: loading ? 0.6 : 1,
                              child: AuthPrimaryButton(
                                label: loading
                                    ? 'common.loading'
                                    : 'common.continue',
                                onTap: () => _onSubmit(context),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _onContinue(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: ResponsiveText(
                            'create_profiles.skip',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.dateSoft,
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
    );
  }
}

class _DraftList extends StatelessWidget {
  const _DraftList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildDraftCubit, ChildDraftState>(
      // Rebuild only on structural changes (add/remove/avatar/password
      // presence). Text edits emit too, but they never reach this widget
      // so the keyboard caret and focus stay intact.
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
      // Password is set via a sheet (no inline cursor), so rebuilding the
      // row on password change is safe and required to flip the pill.
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
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 10 * 0.32,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              height: 1.15,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'create_profiles.title_prefix'.tr()),
              TextSpan(
                text: 'create_profiles.title_accent'.tr(),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.textArabic,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'create_profiles.subtitle',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.dateSoft,
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
                style: TextStyle(
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
