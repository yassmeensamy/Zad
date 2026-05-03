import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/utils/random_tint.dart';
import '../../data/models/level_model.dart';
import '../../data/repositories/levels_repository.dart';
import '../cubit/levels_cubit.dart';
import '../cubit/levels_state.dart';
import '../utils/level_status_styles.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({
    super.key,
    required this.categoryId,
    this.category,
  });

  final String categoryId;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(categoryId) ?? -1;

    return BlocProvider<LevelsCubit>(
      create: (_) => sl<LevelsCubit>()..getLevels(id),
      child: _LevelsView(categoryId: id, category: category),
    );
  }
}

class _LevelsView extends StatefulWidget {
  const _LevelsView({required this.categoryId, this.category});

  final int categoryId;
  final CategoryModel? category;

  @override
  State<_LevelsView> createState() => _LevelsViewState();
}

class _LevelsViewState extends State<_LevelsView>
    with ScrollPaginationMixin<_LevelsView> {
  late final Color _tint =
      widget.category != null ? tintFor(widget.category!.id) : randomTint();

  @override
  void onLoadMore() {
    context.read<LevelsCubit>().loadMore(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Column(
        children: [
          ZaadAppBar(
            title: widget.category?.name ?? 'levels.title',
            onBack: context.canPop() ? () => context.pop() : null,
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: StarTessellationPainter(
                        color: _tint,
                        tile: 56,
                        opacity: 0.04,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<LevelsCubit, LevelsState>(
                  builder: (context, state) {
                    if ((state.isLoading || state.isInitial) &&
                        !state.hasLevels) {
                      return _LevelsLoading(
                        tint: _tint,
                        category: widget.category,
                      );
                    }
                    if (state.isError && !state.hasLevels) {
                      return ErrorState(
                        message: state.errorMessage ?? 'errors.generic',
                        onRetry: () => context
                            .read<LevelsCubit>()
                            .getLevels(widget.categoryId),
                      );
                    }
                    return _LevelsList(
                      controller: scrollController,
                      state: state,
                      tint: _tint,
                      category: widget.category,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelsList extends StatelessWidget {
  const _LevelsList({
    this.controller,
    required this.state,
    required this.tint,
    this.category,
  });

  final ScrollController? controller;
  final LevelsState state;
  final Color tint;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final levels = state.levels;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      physics: const BouncingScrollPhysics(),
      children: [
        _Hero(state: state, tint: tint, category: category),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StarRule(color: tint, starSize: 10),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < levels.length; i++)
          _TimelineRow(
            level: levels[i],
            tint: tint,
            isFirst: i == 0,
            isLast: i == levels.length - 1,
          ),
        if (state.isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: tint),
              ),
            ),
          ),
      ],
    );
  }
}

class _LevelsLoading extends StatelessWidget {
  const _LevelsLoading({required this.tint, this.category});

  final Color tint;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final placeholders = sl<LevelsRepository>().getPlaceholders();
    final mockState = LevelsState(
      status: LevelsStatus.loaded,
      levels: placeholders,
    );
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: _LevelsList(state: mockState, tint: tint, category: category),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.level,
    required this.tint,
    required this.isFirst,
    required this.isLast,
  });

  final LevelModel level;
  final Color tint;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: isFirst ? 28 : 0,
                      bottom: isLast ? 28 : 0,
                    ),
                    child: Center(
                      child: Container(
                        width: 2,
                        color: level.isCompleted
                            ? tint.withValues(alpha: 0.55)
                            : colors.borderSubtle,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _Badge(level: level, tint: tint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LevelCard(level: level, tint: tint),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locked = level.isLocked;

    final borderColor = level.status.tileBorder(colors, tint);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: locked ? null : () {},
        borderRadius: ZaadRadii.xlAll,
        splashColor: tint.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: locked
                ? colors.canvasRaised.withValues(alpha: 0.55)
                : colors.canvasRaised,
            borderRadius: ZaadRadii.xlAll,
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            level.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.1,
                              color: locked
                                  ? colors.textTertiary
                                  : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ResponsiveText(
                            'levels.questions'.tr(args: [
                              '${level.completedQuestions}',
                              '${level.questionCount}',
                            ]),
                            style: AppTextStyles.labelMedium.copyWith(
                              letterSpacing: 0,
                              color: locked
                                  ? colors.textPlaceholder
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(level: level, tint: tint),
                  ],
                ),
                if (level.questionCount > 0 && !locked) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    child: Stack(
                      children: [
                        Container(
                          height: 5,
                          color: tint.withValues(alpha: 0.12),
                        ),
                        FractionallySizedBox(
                          widthFactor: level.progress,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: tint,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ResponsiveText(
                        'levels.percent'.tr(args: ['${level.progressPercent}']),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tint,
                        ),
                      ),
                      const Spacer(),
                      if (level.passingGrade > 0)
                        ResponsiveText(
                          'levels.pass'.tr(args: ['${level.passingGrade}']),
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final palette = level.status.badgeColors(context.appColors, tint);
    final icon = level.status.badgeIcon;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.bg,
        border: Border.all(color: palette.border, width: 1.4),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon.icon, size: icon.size, color: palette.fg)
          : ResponsiveText(
              '${level.order}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: palette.fg,
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final style = level.status.chipStyle(context.appColors, tint);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: style.fg),
          const SizedBox(width: 4),
          ResponsiveText(
            style.labelKey,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.state,
    required this.tint,
    this.category,
  });

  final LevelsState state;
  final Color tint;
  final CategoryModel? category;

  String? get _iconUrl => category?.iconUrl;
  int? get _fallbackTotal => category?.levelCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final completed = state.completedCount;
    final total = state.totalCount == 0
        ? (_fallbackTotal ?? 0)
        : state.totalCount;
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

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
      child: ClipRRect(
        borderRadius: ZaadRadii.xxlAll,
        child: Stack(
          children: [
            IslamicPatternCorner(
              color: tint,
              size: 100,
              tile: 20,
              opacity: 0.16,
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
                          if (_iconUrl != null && _iconUrl!.isNotEmpty)
                            ClipOval(
                              child: Image.network(
                                _iconUrl!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.menu_book_outlined,
                                  size: 24,
                                  color: tint,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.menu_book_outlined,
                              size: 24,
                              color: tint,
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
                            'levels.eyebrow',
                            style: ZaadType.eyebrowSm.copyWith(color: tint),
                          ),
                          const SizedBox(height: 4),
                          ResponsiveText(
                            'levels.heading'.tr(args: [
                              '$completed',
                              '$total',
                            ]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: colors.textPrimary,
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
                        widthFactor: progress,
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
                    ResponsiveText(
                      'levels.percent'.tr(args: ['$percent']),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        color: tint,
                      ),
                    ),
                    const Spacer(),
                    ResponsiveText(
                      'levels.count'.tr(args: ['$completed', '$total']),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
