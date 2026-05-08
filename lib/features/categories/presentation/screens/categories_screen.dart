import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/repositories/categories_repository.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../utils/random_tint.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>(
      create: (_) => sl<CategoriesCubit>()..getCategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.canvas,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const _BackdropOrnament(),
            BlocBuilder<CategoriesCubit, CategoriesState>(
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
                    ? sl<CategoriesRepository>().getPlaceholders()
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
                            overallProgress:
                                isLoading ? 0 : state.overallProgress,
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
          ],
        ),
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
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: KhatimStarPainter(
                        fill: colors.accent.withValues(alpha: 0.10),
                        stroke: colors.accent.withValues(alpha: 0.55),
                        strokeWidth: 0.9,
                      ),
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: colors.accentDeep,
                  ),
                ),
              ],
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
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: colors.accent.withValues(alpha: 0.15),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0, 1),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.accent, colors.olive],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropOrnament extends StatelessWidget {
  const _BackdropOrnament();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: StarTessellationPainter(
              color: context.appColors.accent,
              tile: 56,
              opacity: 0.035,
            ),
          ),
        ),
      ),
    );
  }
}
