import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/random_tint.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gradient_progress_bar.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/star_medallion.dart';
import '../../../../theme/theme.dart';
import '../../data/models/category_model.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/category_card.dart';

const List<CategoryModel> _kPlaceholders = [
  CategoryModel(
    id: 0,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 0,
  ),
  CategoryModel(
    id: 1,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 1,
  ),
  CategoryModel(
    id: 2,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 2,
  ),
  CategoryModel(
    id: 3,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 3,
  ),
  CategoryModel(
    id: 4,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 4,
  ),
  CategoryModel(
    id: 5,
    name: 'Category title',
    description:
        'A short two-line description that hints at what this theme is about.',
    iconUrl: '',
    levelCount: 6,
    completedLevels: 2,
    orderIndex: 5,
  ),
];

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>.value(
      value: sl<CategoriesCubit>()..ensureLoaded(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          BlocListener<CategoriesCubit, CategoriesState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null &&
                curr.hasCategories,
            listener: (context, state) => SnackBarHelper.showError(
              context,
              message: state.errorMessage ?? 'errors.generic',
            ),
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  !listEquals(prev.categories, curr.categories),
              builder: (context, state) {
                if (state.isError && !state.hasCategories) {
                  return ErrorState(
                    message: state.errorMessage ?? 'errors.generic',
                    onRetry: () =>
                        context.read<CategoriesCubit>().getCategories(),
                  );
                }

                final isLoading = state.isLoading || state.isInitial;
                final categories = isLoading
                    ? _kPlaceholders
                    : state.categories;

                return Skeletonizer(
                  enabled: isLoading,
                  effect: ShimmerEffect(
                    baseColor: colors.olive.withValues(alpha: 0.10),
                    highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
                  ),
                  child: CustomScrollView(
                    physics: isLoading
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
                        sliver: SliverToBoxAdapter(
                          child: _Header(
                            overallProgress: isLoading
                                ? 0
                                : state.overallProgress,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        sliver: SliverToBoxAdapter(
                          child: StarRule(color: colors.accent, starSize: 10),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 22)),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverGrid.builder(
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.82,
                              ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryCard(
                              category: category,
                              tint: tintFor(category.id),
                              onTap: isLoading
                                  ? () {}
                                  : () => context.pushNamed(
                                      AppRoutes.levelsName,
                                      pathParameters: {
                                        'id': category.id.toString(),
                                      },
                                      extra: category,
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.overallProgress});

  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'categories.eyebrow',
          style: ZaadType.eyebrow.copyWith(
            color: colors.accentDeep.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          'categories.title',
          style: ZaadType.titleHero.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          'categories.subtitle',
          style: ZaadType.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 18),
        _OverallProgress(progress: overallProgress),
      ],
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.canvasRaised,
        borderRadius: ZaadRadii.xlAll,
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          StarMedallion(
            size: 44,
            tint: colors.accent,
            child: Text(
              '$percent%',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: colors.accentDeep,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'categories.overall.label',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GradientProgressBar(
                  progress: progress,
                  trackColor: colors.accent.withValues(alpha: 0.15),
                  gradientColors: [colors.accent, colors.olive],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
