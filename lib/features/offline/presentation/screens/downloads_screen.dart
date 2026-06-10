import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../cubit/downloads_cubit.dart';
import '../cubit/downloads_state.dart';

/// Manage downloaded categories available offline: review and remove them.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadsCubit>(
      create: (_) => sl<DownloadsCubit>()..load(),
      child: const _DownloadsView(),
    );
  }
}

class _DownloadsView extends StatelessWidget {
  const _DownloadsView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: ZaadAppBar(
        title: 'downloads.title',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: BlocBuilder<DownloadsCubit, DownloadsState>(
        builder: (context, state) {
          if (state.status == DownloadsStatus.initial ||
              state.status == DownloadsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DownloadsStatus.error &&
              state.downloadedCategories.isEmpty) {
            return ErrorState(
              message: state.errorMessage ?? 'downloads.error',
              onRetry: () => context.read<DownloadsCubit>().load(),
            );
          }
          if (state.downloadedCategories.isEmpty) {
            return const EmptyState(
              icon: Icons.download_done_rounded,
              title: 'downloads.empty',
              subtitle: 'downloads.empty_subtitle',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: state.downloadedCategories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _DownloadedTile(
              category: state.downloadedCategories[index],
            ),
          );
        },
      ),
    );
  }
}

class _DownloadedTile extends StatelessWidget {
  const _DownloadedTile({required this.category});

  final CategoryModel category;

  Future<void> _confirmRemove(BuildContext context) async {
    final cubit = context.read<DownloadsCubit>();
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      titleKey: 'downloads.remove',
      messageKey: 'downloads.remove_confirm',
      confirmKey: 'downloads.remove',
    );
    if (confirmed != true) return;
    await cubit.remove(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.canvasRaised,
        borderRadius: ZaadRadii.xlAll,
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 22, color: colors.accentDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'downloads.levels_count'.tr(args: ['${category.levelCount}']),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'downloads.remove'.tr(),
            icon: Icon(Icons.delete_outline_rounded, color: context.colorScheme.error),
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }
}
