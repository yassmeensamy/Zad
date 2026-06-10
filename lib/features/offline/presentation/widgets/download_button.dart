import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../cubit/downloads_cubit.dart';
import '../cubit/downloads_state.dart';

/// Small download affordance for a category card. Reflects three states from
/// [DownloadsCubit]: idle (tap to download), downloading (progress ring) and
/// downloaded (check). Requires a [DownloadsCubit] above it in the tree.
class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<DownloadsCubit, DownloadsState>(
      buildWhen: (a, b) =>
          a.isDownloaded(category.id) != b.isDownloaded(category.id) ||
          a.isDownloading(category.id) != b.isDownloading(category.id) ||
          a.progress[category.id] != b.progress[category.id],
      builder: (context, state) {
        final isDownloaded = state.isDownloaded(category.id);
        final isDownloading = state.isDownloading(category.id);

        Widget child;
        VoidCallback? onTap;
        if (isDownloading) {
          final value = state.progress[category.id] ?? 0;
          child = SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: value == 0 ? null : value,
              valueColor: AlwaysStoppedAnimation(colors.accentDeep),
            ),
          );
        } else if (isDownloaded) {
          child = Icon(
            Icons.download_done_rounded,
            size: 18,
            color: colors.accentDeep,
          );
        } else {
          child = Icon(
            Icons.download_rounded,
            size: 18,
            color: colors.accentDeep,
          );
          onTap = () => context.read<DownloadsCubit>().download(category);
        }

        return Material(
          color: colors.canvas.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
