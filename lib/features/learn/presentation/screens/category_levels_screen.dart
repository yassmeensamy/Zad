import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../data/models/learn_category.dart';
import '../../data/models/learn_level.dart';
import '../cubit/learn_cubit.dart';
import '../cubit/learn_state.dart';
import '../utils/random_tint.dart';
import '../widgets/level_tile.dart';

class CategoryLevelsScreen extends StatelessWidget {
  const CategoryLevelsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final id = LearnCategoryId.values.firstWhere(
      (e) => e.name == categoryId,
      orElse: () => LearnCategoryId.companions,
    );

    final parentCubit = _readParentCubit(context);
    if (parentCubit != null) {
      return BlocProvider<LearnCubit>.value(
        value: parentCubit,
        child: _CategoryLevelsView(id: id),
      );
    }

    return BlocProvider<LearnCubit>(
      create: (_) => sl<LearnCubit>()..getCategories(),
      child: _CategoryLevelsView(id: id),
    );
  }

  LearnCubit? _readParentCubit(BuildContext context) {
    try {
      return context.read<LearnCubit>();
    } catch (_) {
      return null;
    }
  }
}

class _CategoryLevelsView extends StatefulWidget {
  const _CategoryLevelsView({required this.id});

  final LearnCategoryId id;

  @override
  State<_CategoryLevelsView> createState() => _CategoryLevelsViewState();
}

class _CategoryLevelsViewState extends State<_CategoryLevelsView> {
  late final Color _tint = randomTint();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: BlocBuilder<LearnCubit, LearnState>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const _Scaffolded(child: _LoadingIndicator());
          }
          final category = state.findById(widget.id);
          if (state.isError && category == null) {
            return _Scaffolded(
              child: ErrorState(
                message: state.errorMessage ?? 'errors.generic',
                onRetry: () =>
                    context.read<LearnCubit>().getCategories(),
              ),
            );
          }
          if (category == null) {
            return const _Scaffolded(child: SizedBox.shrink());
          }
          return _LevelsList(category: category, tint: _tint);
        },
      ),
    );
  }
}

class _LevelsList extends StatelessWidget {
  const _LevelsList({required this.category, required this.tint});

  final LearnCategory category;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZaadAppBar(
          title: category.titleKey,
          subtitle: category.subtitleKey,
          onBack: context.canPop() ? () => context.pop() : null,
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: StarTessellationPainter(
                      color: tint,
                      tile: 56,
                      opacity: 0.04,
                    ),
                  ),
                ),
              ),
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                physics: const BouncingScrollPhysics(),
                children: [
                  _Hero(category: category, tint: tint),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StarRule(color: tint, starSize: 10),
                  ),
                  const SizedBox(height: 22),
                  for (var i = 0; i < category.levels.length; i++)
                    LevelTile(
                      level: category.levels[i],
                      tint: tint,
                      isLast: i == category.levels.length - 1,
                      onTap: () => _openLevel(context, category.levels[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLevel(BuildContext context, LearnLevel level) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(level.titleKey.tr()),
      ),
    );
  }
}

class _Scaffolded extends StatelessWidget {
  const _Scaffolded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZaadAppBar(
          title: 'learn.title',
          onBack: context.canPop() ? () => context.pop() : null,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: colors.accent,
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.category, required this.tint});

  final LearnCategory category;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = category.progressPercent;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xxlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvasRaised,
            Color.lerp(colors.canvas, tint, 0.07)!,
          ],
        ),
        border: Border.all(color: tint.withValues(alpha: 0.22), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: ZaadRadii.xxlAll,
            child: IslamicPatternCorner(
              color: tint,
              size: 140,
              tile: 22,
              opacity: 0.18,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: KhatimStarPainter(
                              fill: tint.withValues(alpha: 0.10),
                              stroke: tint.withValues(alpha: 0.55),
                              strokeWidth: 0.9,
                            ),
                          ),
                        ),
                        Icon(category.icon, size: 24, color: tint),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          'learn.levels_screen.eyebrow',
                          style: ZaadType.eyebrowSm.copyWith(color: tint),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'learn.levels_screen.heading'.tr(args: [
                            '${category.completedLevels}',
                            '${category.totalLevels}',
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: tint.withValues(alpha: 0.12),
                    ),
                    FractionallySizedBox(
                      widthFactor: category.progress.clamp(0, 1),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.lerp(tint, colors.accent, 0.25)!,
                              tint,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'learn.progress.percent'.tr(args: ['$percent']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: tint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        'learn.progress.levels'.tr(args: [
                          '${category.completedLevels}',
                          '${category.totalLevels}',
                        ]),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
