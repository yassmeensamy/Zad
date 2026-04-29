import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../onboarding_flow/data/child_avatar.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_draft_cubit.dart';
import '../cubit/child_draft_state.dart';
import '../cubit/child_state.dart';
import '../widgets/kid_card.dart';

class ChildrenListScreen extends StatelessWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChildCubit>(
          create: (_) => sl<ChildCubit>()..fetchChildren(),
        ),
        BlocProvider<ChildDraftCubit>(create: (_) => sl<ChildDraftCubit>()),
      ],
      child: const _ChildrenListView(),
    );
  }
}

class _ChildrenListView extends StatelessWidget {
  const _ChildrenListView();

  Future<void> _save(BuildContext context) async {
    final draftCubit = context.read<ChildDraftCubit>();
    if (!draftCubit.validate()) return;

    final draft = draftCubit.state;
    if (!draft.hasPending) return;

    final cubit = context.read<ChildCubit>();
    await Future.wait([
      for (final id in draft.pendingDeletes) cubit.deleteChild(id),
      for (final d in draft.dirtyExisting) _updateOne(cubit, d, draft),
      if (draft.newDrafts.isNotEmpty)
        cubit.createChildren([
          for (final d in draft.newDrafts)
            (
              username: d.name.trim(),
              fullName: d.name.trim(),
              password: d.password,
              birthDate: d.inferredBirthDate,
            ),
        ]),
    ]);
  }

  Future<void> _updateOne(
    ChildCubit cubit,
    ChildDraft d,
    ChildDraftState draft,
  ) {
    final name = d.name.trim();
    return cubit.updateChild(
      childId: d.id,
      fullName: name.isEmpty ? null : name,
      birthDate: d.inferredBirthDate,
      password: d.password == draft.originals[d.id]!.password
          ? null
          : d.password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZadAppBar(
        title: 'profile.my_children',
        onBack: () => context.pop(),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChildCubit, ChildState>(
            listenWhen: (a, b) => a.status != b.status && b.isLoaded,
            listener: (context, state) {
              context.read<ChildDraftCubit>().loadFromServer(state.children);
            },
          ),
          BlocListener<ChildCubit, ChildState>(
            listenWhen: (a, b) => a.actionStatus != b.actionStatus,
            listener: (context, state) {
              if (state.isActionLoaded) {
                context.read<ChildCubit>().fetchChildren();
                context.read<ChildCubit>().resetActionStatus();
              } else if (state.isActionError &&
                  state.actionErrorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: ResponsiveText(state.actionErrorMessage),
                  ),
                );
                context.read<ChildCubit>().resetActionStatus();
              }
            },
          ),
          BlocListener<ChildDraftCubit, ChildDraftState>(
            listenWhen: (a, b) =>
                b.validationError != null &&
                a.validationError != b.validationError,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ResponsiveText(state.validationError),
                ),
              );
              context.read<ChildDraftCubit>().clearError();
            },
          ),
        ],
        child: BlocBuilder<ChildCubit, ChildState>(
          buildWhen: (a, b) => a.status != b.status,
          builder: (context, state) {
            if (state.isLoading || state.isInitial) {
              return const _LoadingSkeleton();
            }
            if (state.isError) {
              return ErrorState(
                message: state.errorMessage ?? 'children_list.load_failed',
                onRetry: () => context.read<ChildCubit>().fetchChildren(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChildDraftCubit, ChildDraftState>(
                    buildWhen: (a, b) => a.drafts.length != b.drafts.length,
                    builder: (context, draftState) {
                      if (draftState.drafts.isEmpty) {
                        return const EmptyState(
                          icon: Icons.family_restroom_rounded,
                          title: 'profile.my_children',
                          subtitle: 'children_list.empty_hint',
                        );
                      }
                      return const _DraftList();
                    },
                  ),
                ),
                _BottomBar(
                  onSave: () => _save(context),
                  onAdd: () => context.read<ChildDraftCubit>().add(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  static const _mockDrafts = [
    ChildDraft(
      id: 'mock-1',
      name: 'Yusuf Ali',
      age: '7',
      password: '••••',
      avatar: ChildAvatar.palm,
    ),
    ChildDraft(
      id: 'mock-2',
      name: 'Maryam Hassan',
      age: '9',
      password: '••••',
      avatar: ChildAvatar.crescent,
    ),
    ChildDraft(
      id: 'mock-3',
      name: 'Omar Ahmed',
      age: '5',
      password: '••••',
      avatar: ChildAvatar.star,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockDrafts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  KidCard(draft: _mockDrafts[i], showRemove: true),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.olive.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          physics: const BouncingScrollPhysics(),
          itemCount: drafts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final draft = drafts[i];
            return KidCard(
              key: ValueKey(draft.id),
              draft: draft,
              showRemove: true,
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onSave, required this.onAdd});

  final Future<void> Function() onSave;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: BlocBuilder<ChildDraftCubit, ChildDraftState>(
          builder: (context, state) {
            final hasPending = state.hasPending;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPending) ...[
                  CustomButton.full(
                    text: 'common.save',
                    onTap: onSave,
                    theme: CustomButtonTheme(
                      height: 48,
                      backgroundColor: colors.olive,
                      textColor: colors.canvas,
                      borderRadius: 14,
                      textStyle: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.canvas,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                CustomButton.full(
                  onTap: onAdd,
                  theme: CustomButtonTheme(
                    height: 48,
                    backgroundColor: colors.olive.withValues(alpha: 0.06),
                    borderColor: colors.olive.withValues(alpha: 0.5),
                    borderRadius: 14,
                    textColor: colors.olive,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: colors.olive,
                      ),
                      const SizedBox(width: 8),
                      ResponsiveText(
                        'create_profiles.add_child',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.olive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

