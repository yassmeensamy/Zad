import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/custom_modal.dart';
import '../../../../theme/theme.dart';
import '../../../onboarding_flow/data/avatar_model.dart';
import '../../../onboarding_flow/presentation/cubit/avatars_cubit.dart';
import '../../../onboarding_flow/presentation/cubit/avatars_state.dart';

/// Bottom sheet that lists remote avatars from `/api/avatars`.
/// Pops with the selected [AvatarModel] (or null if dismissed).
class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({super.key, this.current});

  /// Currently-selected avatar; highlighted in the grid once loaded.
  final AvatarModel? current;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AvatarsCubit>(
      create: (_) => sl<AvatarsCubit>()..fetchAvatars(),
      child: _AvatarPickerView(current: current),
    );
  }
}

class _AvatarPickerView extends StatelessWidget {
  const _AvatarPickerView({required this.current});

  final AvatarModel? current;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomModal(
      title: ResponsiveText(
        'create_profiles.sheet_title',
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: colors.oliveDeep,
        ),
      ),
      subtitle: ResponsiveText(
        'create_profiles.sheet_sub',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: AppColors.dateSoft,
        ),
      ),
      child: BlocBuilder<AvatarsCubit, AvatarsState>(
        buildWhen: (a, b) =>
            a.status != b.status || a.avatars.length != b.avatars.length,
        builder: (context, state) {
          if (state.isError) {
            return _ErrorState(
              onRetry: () => context.read<AvatarsCubit>().fetchAvatars(),
            );
          }
          if (state.isInitial || state.isLoading) {
            return _LoadingGrid(colors: colors);
          }
          return _RemoteGrid(
            avatars: state.avatars,
            currentId: current?.id,
            colors: colors,
          );
        },
      ),
    );
  }
}

/// Skeleton placeholders shown while the remote avatar list loads.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.colors});

  final AppColorsTheme colors;

  static const _placeholderCount = 8;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: _placeholderCount,
        itemBuilder: (_, _) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.olive.withValues(alpha: 0.10),
          ),
        ),
      ),
    );
  }
}

class _RemoteGrid extends StatelessWidget {
  const _RemoteGrid({
    required this.avatars,
    required this.currentId,
    required this.colors,
  });

  final List<AvatarModel> avatars;
  final String? currentId;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ResponsiveText(
          'create_profiles.no_avatars',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.dateSoft),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: avatars.length,
      itemBuilder: (_, i) {
        final a = avatars[i];
        final active = a.id == currentId;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(a),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? colors.olive : Colors.transparent,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CachedNetworkImage(
                    imageUrl: a.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: colors.olive.withValues(alpha: 0.08),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: colors.olive.withValues(alpha: 0.10),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_rounded,
                        color: colors.oliveSoft,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.oliveSoft, size: 32),
          const SizedBox(height: 8),
          ResponsiveText(
            'create_profiles.avatars_load_failed',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.dateSoft),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: ResponsiveText(
              'common.retry',
              style: AppTextStyles.labelLarge.copyWith(color: colors.olive),
            ),
          ),
        ],
      ),
    );
  }
}
