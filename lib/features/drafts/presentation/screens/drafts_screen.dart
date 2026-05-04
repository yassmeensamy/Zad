import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../data/models/draft_model.dart';
import '../cubit/drafts_cubit.dart';
import '../cubit/drafts_state.dart';
import '../widgets/draft_card.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DraftsCubit>(
      create: (_) => sl<DraftsCubit>()..load(),
      child: const _DraftsView(),
    );
  }
}

class _DraftsView extends StatelessWidget {
  const _DraftsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZaadAppBar(
        title: 'drafts.title',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DraftsCubit, DraftsState>(
            listenWhen: (a, b) =>
                a.errorMessage != b.errorMessage && b.errorMessage != null,
            listener: (context, state) {
              SnackBarHelper.showError(
                context,
                message: state.errorMessage!,
              );
            },
          ),
          BlocListener<DraftsCubit, DraftsState>(
            listenWhen: (a, b) =>
                a.crudStatus != b.crudStatus &&
                b.crudStatus == CrudStatus.error,
            listener: (context, state) {
              SnackBarHelper.showError(
                context,
                message: state.crudErrorMessage ?? 'errors.generic',
              );
            },
          ),
        ],
        child: BlocBuilder<DraftsCubit, DraftsState>(
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.drafts != b.drafts ||
              a.mutatingIds != b.mutatingIds,
          builder: (context, state) {
            if (state.isInitial || state.isLoading) {
              return const _LoadingSkeleton();
            }
            if (state.isError) {
              return ErrorState(
                message: state.errorMessage ?? 'drafts.load_failed',
                onRetry: () => context.read<DraftsCubit>().load(),
              );
            }
            if (!state.hasDrafts) {
              return const EmptyState(
                icon: Icons.bookmarks_outlined,
                title: 'drafts.empty_title',
                subtitle: 'drafts.empty_subtitle',
              );
            }
            return RefreshIndicator(
              color: colors.olive,
              onRefresh: () =>
                  context.read<DraftsCubit>().load(isRefresh: true),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: state.drafts.length,
                itemBuilder: (context, index) {
                  final draft = state.drafts[index];
                  return DraftCard(
                    draft: draft,
                    isMutating: state.isMutating(draft.id),
                    onTap: () => _onView(context, draft),
                    onDelete: () => _onDelete(context, draft),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _onView(BuildContext context, DraftModel draft) {
    context.pushNamed(
      AppRoutes.draftDetailName,
      pathParameters: {'id': draft.id.toString()},
      extra: (cubit: context.read<DraftsCubit>(), draft: draft),
    );
  }

  void _onDelete(BuildContext context, DraftModel draft) {
    context.read<DraftsCubit>().delete(draft.id);
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  static const _rowCount = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: _rowCount,
        itemBuilder: (_, _) => const DraftCardSkeleton(),
      ),
    );
  }
}
