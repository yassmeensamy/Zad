import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../home/presentation/widgets/home_why_login_section.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../cubit/rankings_cubit.dart';
import '../cubit/rankings_state.dart';
import '../widgets/leaderboard_no_team.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingsCubit>(create: (_) => sl<RankingsCubit>()),
        BlocProvider<CategoriesCubit>.value(value: sl<CategoriesCubit>()),
      ],
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatefulWidget {
  const _LeaderboardView();

  @override
  State<_LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<_LeaderboardView>
    with ScrollPaginationMixin {
  bool _branchVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_branchVisible) {
      _branchVisible = true;
      _loadOnEnter();
    } else if (!visible) {
      _branchVisible = false;
    }
  }

  void _loadOnEnter() {
    final isGuest = context.read<UserCubit>().state.user?.isAnonymous ?? false;
    if (isGuest) return;
    context.read<CategoriesCubit>().ensureLoaded();
    context.read<RankingsCubit>().refresh();
  }

  @override
  void onLoadMore() => context.read<RankingsCubit>().loadMore();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final view = View.of(context);
    final bottomInset = view.viewPadding.bottom / view.devicePixelRatio;
    final bottomNavSpace = 64 + bottomInset + 10;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: _EmberBackdrop(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 8 + bottomNavSpace),
            child: BlocSelector<UserCubit, UserState, bool>(
              selector: (state) => state.user?.isAnonymous ?? false,
              builder: (context, isGuest) {
                if (isGuest) return const _GuestPrompt();
                return BlocBuilder<RankingsCubit, RankingsState>(
                  builder: (context, state) {
                    final cubit = context.read<RankingsCubit>();
                    return Column(
                      children: [
                        const _Header(),
                        const SizedBox(height: 14),
                        _ScopeSegmented(
                          value: state.scope,
                          onChanged: cubit.setScope,
                        ),
                        if (state.isIndividuals) ...[
                          const SizedBox(height: 12),
                          BlocSelector<
                            CategoriesCubit,
                            CategoriesState,
                            List<CategoryModel>
                          >(
                            selector: (catState) => catState.categories,
                            builder: (context, categories) => _CategoryFilter(
                              categories: categories,
                              selectedId: state.categoryId,
                              onSelected: cubit.setCategory,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Expanded(
                          child: _Body(
                            state: state,
                            controller: scrollController,
                          ),
                        ),
                        _Footer(state: state),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: HomeWhyLoginSection(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmberBackdrop extends StatelessWidget {
  const _EmberBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1.05),
          radius: 1.35,
          colors: [
            colors.backdropTop,
            colors.backdropMid,
            colors.backdropBottom,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.06,
                child: Image(
                  image: const AssetImage('assets/images/islamic-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  color: isDark ? colors.textPrimary : colors.textTertiary,
                  colorBlendMode: isDark
                      ? BlendMode.screen
                      : BlendMode.multiply,
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            right: -120,
            top: -120,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [
                      colors.accent.withValues(alpha: isDark ? 0.22 : 0.16),
                      colors.accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: _EmberField(core: colors.accentSoft, glow: colors.accent),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        ResponsiveText(
          'leaderboard.eyebrow'.tr().toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 4),
        ResponsiveText(
          'leaderboard.title'.tr(),
          style: AppTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            height: 1,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ScopeSegmented extends StatelessWidget {
  const _ScopeSegmented({required this.value, required this.onChanged});

  final RankingsScope value;
  final ValueChanged<RankingsScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          for (final scope in RankingsScope.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(scope),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: scope == value
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.accent.withValues(alpha: 0.20),
                              colors.accentDeep.withValues(alpha: 0.12),
                            ],
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: ResponsiveText(
                    scope.labelKey.tr().toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: scope == value
                          ? colors.accent
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _CategoryChip(
            label: 'leaderboard.category_all'.tr(),
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final c in categories)
            _CategoryChip(
              label: c.name,
              selected: selectedId == c.id,
              onTap: () => onSelected(c.id),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap();
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.accent.withValues(alpha: 0.20),
                      colors.accentDeep.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            color: selected ? null : colors.cardSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? colors.accent.withValues(alpha: 0.45)
                  : colors.borderSubtle,
            ),
          ),
          child: ResponsiveText(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? colors.accent : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final RankingsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (state.activeStatus == RankingsStatus.loading && state.activeIsEmpty) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: colors.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (state.activeStatus == RankingsStatus.error && state.activeIsEmpty) {
      return _ErrorRetry(
        onRetry: () => context.read<RankingsCubit>().refresh(),
      );
    }
    if (state.isTeams &&
        state.teamStatus == RankingsStatus.success &&
        state.myTeamRank == null) {
      return LeaderboardNoTeam(
        onChanged: () => context.read<RankingsCubit>().refresh(),
      );
    }
    if (state.activeIsEmpty) {
      return const _EmptyHint(textKey: 'leaderboard.empty');
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 8),
          sliver: SliverList.list(
            children: [
              const _EyebrowRule(label: 'PODIUM'),
              const SizedBox(height: 11),
              _Podium(seeds: _podium(state)),
              const SizedBox(height: 14),
              _AllMembersRule(count: state.activeCount),
              const SizedBox(height: 10),
            ],
          ),
        ),
        SliverList.separated(
          itemCount: state.activeCount,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) => _RankRow(seed: _rowAt(state, i)),
        ),
        if (state.loadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: colors.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<_RankSeed> _podium(RankingsState state) => state.isIndividuals
      ? [
          for (final r in state.individuals.take(3))
            _RankSeed(
              rank: r.rank,
              name: r.username,
              completed: r.completedLevels,
              total: r.totalLevels,
            ),
        ]
      : [
          for (final t in state.teams.take(3))
            _RankSeed(
              rank: t.rank,
              name: t.teamName,
              completed: t.totalCompletedLevels,
              total: t.totalLevels,
            ),
        ];

  _RankSeed _rowAt(RankingsState state, int i) {
    if (state.isIndividuals) {
      final r = state.individuals[i];
      final myRank = state.myRank?.rank;
      return _RankSeed(
        rank: r.rank,
        name: r.username,
        completed: r.completedLevels,
        total: r.totalLevels,
        isMe: myRank != null && r.rank == myRank,
      );
    }
    final t = state.teams[i];
    final myRank = state.myTeamRank?.rank;
    return _RankSeed(
      rank: t.rank,
      name: t.teamName,
      completed: t.totalCompletedLevels,
      total: t.totalLevels,
      subtitle: 'leaderboard.member_count'.plural(
        t.memberCount,
        args: ['${t.memberCount}'],
      ),
      isMe: myRank != null && t.rank == myRank,
    );
  }
}

class _RankSeed {
  const _RankSeed({
    required this.rank,
    required this.name,
    required this.completed,
    required this.total,
    this.subtitle,
    this.isMe = false,
  });

  final int rank;
  final String name;
  final int completed;
  final int total;
  final String? subtitle;
  final bool isMe;

  int get percent =>
      total <= 0 ? 0 : ((completed / total).clamp(0, 1) * 100).round();
}

class _Podium extends StatelessWidget {
  const _Podium({required this.seeds});

  final List<_RankSeed> seeds;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) {
      return const _EmptyHint(
        textKey: 'leaderboard.podium_empty',
        vertical: 28,
      );
    }
    _RankSeed? at(int i) => i < seeds.length ? seeds[i] : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 100, child: _PodiumPillar(place: 2, seed: at(1))),
          const SizedBox(width: 9),
          Expanded(flex: 115, child: _PodiumPillar(place: 1, seed: at(0))),
          const SizedBox(width: 9),
          Expanded(flex: 100, child: _PodiumPillar(place: 3, seed: at(2))),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({required this.place, required this.seed});

  final int place;
  final _RankSeed? seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isFirst = place == 1;
    final accent = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.emberBright,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    final pedTint = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.ember,
    };
    final avatarSize = isFirst ? 62.0 : 52.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: avatarSize + 14,
          height: avatarSize + (isFirst ? 22 : 14),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize + 14,
                height: avatarSize + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.5),
                      accent.withValues(alpha: 0),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              _Disc(
                size: avatarSize,
                initial: _initial(seed?.name),
                style: _discForPlace(place),
                fontSize: isFirst ? 24 : 20,
              ),
              if (isFirst && seed != null)
                const Positioned(top: -8, child: _Crown()),
              Positioned(
                right: 2,
                bottom: 2,
                child: _RankBadge(place: place, color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        ResponsiveText(
          seed?.name ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? colors.accent : colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          seed == null ? '—' : '${seed!.completed}/${seed!.total}',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: accent,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: pedHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(
              top: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              left: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              right: BorderSide(color: pedTint.withValues(alpha: 0.4)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                pedTint.withValues(alpha: 0.28),
                pedTint.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: ResponsiveText(
            place < 10 ? '0$place' : '$place',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.place, required this.color});
  final int place;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.canvas,
        border: Border.all(color: color, width: 2),
      ),
      child: ResponsiveText(
        '$place',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 16,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 26;
    final sy = size.height / 16;
    final path = Path()
      ..moveTo(1.5 * sx, 14 * sy)
      ..lineTo(4 * sx, 5 * sy)
      ..lineTo(9.5 * sx, 10.5 * sy)
      ..lineTo(13 * sx, 2.5 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(22 * sx, 5 * sy)
      ..lineTo(24.5 * sx, 14 * sy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.discGoldHi, AppColors.discGoldLo],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.discBronzeLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.seed});

  final _RankSeed seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMe = seed.isMe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMe
            ? LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.12),
                  colors.accent.withValues(alpha: 0.02),
                ],
              )
            : null,
        color: isMe ? null : colors.textPrimary.withValues(alpha: 0.024),
        border: Border.all(
          color: isMe
              ? colors.accent.withValues(alpha: 0.4)
              : colors.textPrimary.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: ResponsiveText(
              seed.rank.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? colors.accent : colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Disc(
            size: 38,
            initial: _initial(seed.name),
            style: _discForRow(seed.rank, isMe),
            fontSize: 15,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  isMe
                      ? 'leaderboard.name_you'.tr(
                          namedArgs: {'name': seed.name},
                        )
                      : seed.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: isMe ? colors.accentSoft : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                ResponsiveText(
                  _metaLine(seed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ResponsiveText(
                '${seed.completed}/${seed.total}',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? colors.accentSoft : colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                '${seed.percent}%',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _metaLine(_RankSeed seed) {
    final levels = 'leaderboard.levels_progress'.tr(
      namedArgs: {'completed': '${seed.completed}', 'total': '${seed.total}'},
    );
    final sub = seed.subtitle;
    return sub == null ? levels : '$sub · $levels';
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final RankingsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isIndividuals) {
      final me = state.myRank;
      if (me == null) return const SizedBox.shrink();
      return _MyRankCta(
        label: 'leaderboard.your_rank'.tr(),
        rank: me.rank,
        title: 'leaderboard.you'.tr(),
      );
    }
    final me = state.myTeamRank;
    if (me == null) return const SizedBox.shrink();
    return _MyRankCta(
      label: 'leaderboard.your_team'.tr(),
      rank: me.rank,
      title: me.teamName,
      onTap: () => context.pushNamed(AppRoutes.teamMembersName),
    );
  }
}

class _MyRankCta extends StatelessWidget {
  const _MyRankCta({
    required this.label,
    required this.rank,
    required this.title,
    this.onTap,
  });

  final String label;
  final int rank;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;

    // Dark mode reads as a warm ember highlight. In light, the same cta (olive)
    // tokens washed out to a muddy grey-green over the cream page, so we gild
    // the card instead — a soft gold gradient, a crisp amber hairline and a
    // lighter warm lift — echoing the leaderboard's gold-medal motif. The olive
    // rank badge then pops against it.
    final bgGradient = isDark
        ? [
            colors.ctaMid.withValues(alpha: 0.18),
            colors.ctaBottom.withValues(alpha: 0.08),
          ]
        : [
            colors.accent.withValues(alpha: 0.22),
            colors.accentSoft.withValues(alpha: 0.12),
          ];
    final borderColor = isDark
        ? colors.ctaTop.withValues(alpha: 0.4)
        : colors.accent.withValues(alpha: 0.5);
    final shadow = isDark
        ? BoxShadow(
            color: colors.heroShadow.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 16),
          )
        : BoxShadow(
            color: colors.accent.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          );
    // Deeper amber for the eyebrow + chevron so they keep contrast on the
    // warmer light card (plain accent would blend into the gold wash).
    final accentInk = isDark ? colors.accent : colors.accentDeep;

    final card = Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: bgGradient,
        ),
        border: Border.all(color: borderColor),
        boxShadow: [shadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.ctaTop, colors.ctaMid],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.ctaMid.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ResponsiveText(
              '#$rank',
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onCta,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: accentInk,
                  ),
                ),
                const SizedBox(height: 3),
                ResponsiveText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 16, color: accentInk),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.textKey, this.vertical = 0});

  final String textKey;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Center(
        child: ResponsiveText(
          textKey.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            'leaderboard.error'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: ResponsiveText(
              'common.retry'.tr(),
              style: AppTextStyles.labelLarge.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EyebrowRule extends StatelessWidget {
  const _EyebrowRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _RuleSegment(toRight: true),
        const SizedBox(width: 10),
        ResponsiveText(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: 10),
        const _RuleSegment(toRight: false),
      ],
    );
  }
}

class _AllMembersRule extends StatelessWidget {
  const _AllMembersRule({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0),
              colors.accent.withValues(alpha: 0.30),
              colors.accent.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 8),
        ResponsiveText(
          'leaderboard.all_members'
              .tr(namedArgs: {'count': '$count'})
              .toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        line,
      ],
    );
  }
}

class _RuleSegment extends StatelessWidget {
  const _RuleSegment({required this.toRight});
  final bool toRight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 26,
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: toRight
                ? [colors.accent.withValues(alpha: 0), colors.accent]
                : [colors.accent, colors.accent.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

enum _DiscStyle { gold, silver, bronze, olive }

String _initial(String? name) {
  final t = name?.trim() ?? '';
  return t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();
}

_DiscStyle _discForPlace(int place) => switch (place) {
  1 => _DiscStyle.gold,
  2 => _DiscStyle.silver,
  _ => _DiscStyle.bronze,
};

_DiscStyle _discForRow(int rank, bool isMe) {
  if (isMe) return _DiscStyle.gold;
  return switch (rank) {
    1 => _DiscStyle.gold,
    2 => _DiscStyle.silver,
    3 => _DiscStyle.bronze,
    _ => _DiscStyle.olive,
  };
}

class _Disc extends StatelessWidget {
  const _Disc({
    required this.size,
    required this.initial,
    required this.style,
    required this.fontSize,
  });

  final double size;
  final String initial;
  final _DiscStyle style;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (colors, ink, ringColor) = switch (style) {
      _DiscStyle.gold => (
        [AppColors.discGoldHi, AppColors.discGoldMid, AppColors.discGoldLo],
        AppColors.discGoldInk,
        AppColors.discGoldMid.withValues(alpha: 0.55),
      ),
      _DiscStyle.silver => (
        [
          AppColors.discSilverHi,
          AppColors.discSilverMid,
          AppColors.discSilverLo,
        ],
        AppColors.discGoldInk,
        AppColors.discSilverMid.withValues(alpha: 0.5),
      ),
      _DiscStyle.bronze => (
        [
          AppColors.discBronzeHi,
          AppColors.discBronzeMid,
          AppColors.discBronzeLo,
        ],
        AppColors.discBronzeInk,
        AppColors.discBronzeMid.withValues(alpha: 0.5),
      ),
      _DiscStyle.olive => (
        [AppColors.discOliveHi, AppColors.discOliveMid, AppColors.discOliveLo],
        AppColors.discOliveInk,
        AppColors.discGoldMid.withValues(alpha: 0.2),
      ),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44),
          radius: 0.95,
          colors: colors,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: ringColor, width: 2),
      ),
      child: ResponsiveText(
        initial,
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1,
          color: ink,
        ),
      ),
    );
  }
}

class _EmberField extends StatefulWidget {
  const _EmberField({required this.core, required this.glow});

  final Color core;

  final Color glow;

  @override
  State<_EmberField> createState() => _EmberFieldState();
}

class _EmberFieldState extends State<_EmberField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  final List<_Spark> _sparks = List.generate(14, (i) {
    final rnd = math.Random(i * 7 + 3);
    return _Spark(
      x: rnd.nextDouble(),
      durScale: 0.5 + rnd.nextDouble(),
      sizeScale: 0.5 + rnd.nextDouble() * 0.9,
      phase: rnd.nextDouble(),
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _EmberPainter(
          sparks: _sparks,
          t: _c.value,
          core: widget.core,
          glow: widget.glow,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.x,
    required this.durScale,
    required this.sizeScale,
    required this.phase,
  });
  final double x;
  final double durScale;
  final double sizeScale;
  final double phase;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({
    required this.sparks,
    required this.t,
    required this.core,
    required this.glow,
  });
  final List<_Spark> sparks;
  final double t;
  final Color core;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      final p = (t / s.durScale + s.phase) % 1.0;
      double opacity;
      if (p < 0.12) {
        opacity = (p / 0.12) * 0.7;
      } else if (p < 0.85) {
        opacity = 0.7 - (p - 0.12) / 0.73 * 0.3;
      } else {
        opacity = 0.4 * (1 - (p - 0.85) / 0.15);
      }
      if (opacity <= 0) continue;

      final scale = 0.5 + p * 0.7;
      final radius = 2 * s.sizeScale * scale;
      final dx = s.x * size.width;
      final dy = size.height - p * (size.height + 40);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            core.withValues(alpha: opacity),
            glow.withValues(alpha: opacity * 0.6),
            glow.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.core != core ||
      oldDelegate.glow != glow;
}
