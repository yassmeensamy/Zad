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
import '../../data/models/learn_category.dart';
import '../../data/repositories/learn_repository.dart';
import '../cubit/learn_cubit.dart';
import '../cubit/learn_state.dart';
import '../utils/random_tint.dart';
import '../widgets/category_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearnCubit>(
      create: (_) => sl<LearnCubit>()..getCategories(),
      child: const _LearnView(),
    );
  }
}

class _LearnView extends StatelessWidget {
  const _LearnView();

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
            BlocBuilder<LearnCubit, LearnState>(
              builder: (context, state) {
                if (state.isLoading || state.isInitial) {
                  return const _LoadingSkeleton();
                }
                if (state.isError && !state.hasCategories) {
                  return ErrorState(
                    message: state.errorMessage ?? 'errors.generic',
                    onRetry: () =>
                        context.read<LearnCubit>().getCategories(),
                  );
                }
                return _LoadedView(state: state);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatefulWidget {
  const _LoadedView({required this.state});

  final LearnState state;

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  late List<Color> _tints = randomTints(widget.state.categories.length);

  @override
  void didUpdateWidget(covariant _LoadedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.categories.length != widget.state.categories.length) {
      _tints = randomTints(widget.state.categories.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final overall = widget.state.overallProgress;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
          sliver: SliverToBoxAdapter(
            child: _Header(colors: colors, overallProgress: overall),
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
            itemCount: widget.state.categories.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final category = widget.state.categories[index];
              return CategoryCard(
                category: category,
                tint: _tints[index],
                onTap: () => _openCategory(context, category),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openCategory(BuildContext context, LearnCategory category) {
    context.pushNamed(
      AppRoutes.categoryLevelsName,
      pathParameters: {'id': category.id.name},
    );
  }
}

class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton> {
  late final List<LearnCategory> _placeholders =
      sl<LearnRepository>().getPlaceholders();
  late final List<Color> _tints = randomTints(_placeholders.length);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
            sliver: SliverToBoxAdapter(
              child: _Header(colors: colors, overallProgress: 0.42),
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
              itemCount: _placeholders.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (_, i) => CategoryCard(
                category: _placeholders[i],
                tint: _tints[i],
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors, required this.overallProgress});

  final AppColorsTheme colors;
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final percent = (overallProgress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'learn.eyebrow',
          style: ZaadType.eyebrow.copyWith(
            color: colors.accentDeep.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          'learn.title',
          style: ZaadType.titleHero.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          'learn.subtitle',
          style: ZaadType.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 18),
        _OverallProgress(
          colors: colors,
          progress: overallProgress,
          percent: percent,
        ),
      ],
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({
    required this.colors,
    required this.progress,
    required this.percent,
  });

  final AppColorsTheme colors;
  final double progress;
  final int percent;

  @override
  Widget build(BuildContext context) {
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
                  child: CustomPaint(
                    painter: KhatimStarPainter(
                      fill: colors.accent.withValues(alpha: 0.10),
                      stroke: colors.accent.withValues(alpha: 0.55),
                      strokeWidth: 0.9,
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
                  'learn.overall.label',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius:
                      const BorderRadius.all(Radius.circular(999)),
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
    final colors = context.appColors;
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: StarTessellationPainter(
            color: colors.accent,
            tile: 56,
            opacity: 0.035,
          ),
        ),
      ),
    );
  }
}
