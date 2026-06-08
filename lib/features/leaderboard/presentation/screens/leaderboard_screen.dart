import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../theme/date_ember_palette.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../cubit/rankings_cubit.dart';
import '../cubit/rankings_state.dart';
import '../widgets/leaderboard_no_team.dart';

/// Leaderboard — reskinned with the **Date & Ember** palette
/// (lib/theme/date_ember_palette.dart). Roasted-brown depths, ember accents,
/// gold-foil discs and rising sparks — wired to the live [RankingsCubit] data
/// (scope tabs, category filter, podium, ranking rows, pagination, my-rank).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

// Type families. The design uses Fraunces (serif italic), Inter (sans) and
// JetBrains Mono. We map these to the platform generic families so the screen
// stays self-contained with no font bundling.
const String _serif = 'serif';
const String _mono = 'monospace';

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with ScrollPaginationMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categories = context.read<CategoriesCubit>();
      if (!categories.state.hasCategories) categories.getCategories();
      context.read<RankingsCubit>().loadInitial();
    });
  }

  @override
  void onLoadMore() => context.read<RankingsCubit>().loadMore();

  @override
  Widget build(BuildContext context) {
    // The shell renders an opaque bottom nav (64px + safe-area) with
    // `extendBody: true`, so this branch's content sits *behind* it. Pad the
    // bottom by nav height + inset + a small gap so the pinned footer card
    // clears the bar and stays tappable.
    final view = View.of(context);
    final bottomInset = view.viewPadding.bottom / view.devicePixelRatio;
    final bottomNavSpace = 64 + bottomInset + 10;

    return Scaffold(
      backgroundColor: DateEmber.canvas,
      body: _EmberBackdrop(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 8 + bottomNavSpace),
            child: BlocBuilder<RankingsCubit, RankingsState>(
              builder: (context, state) {
                final cubit = context.read<RankingsCubit>();
                return Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 14),
                    _ScopeSegmented(value: state.scope, onChanged: cubit.setScope),
                    if (state.isIndividuals) ...[
                      const SizedBox(height: 12),
                      BlocBuilder<CategoriesCubit, CategoriesState>(
                        builder: (context, catState) => _CategoryFilter(
                          categories: catState.categories,
                          selectedId: state.categoryId,
                          onSelected: cubit.setCategory,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Expanded(
                      child: _Body(state: state, controller: scrollController),
                    ),
                    _Footer(state: state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background — roasted-brown vignette, Islamic pattern, amber wash, ember field.
// ─────────────────────────────────────────────────────────────────────────────
class _EmberBackdrop extends StatelessWidget {
  const _EmberBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // radial-gradient(130% 75% at 50% -8%, #271A10, #1A120B 42%, #0E0905)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.05),
          radius: 1.35,
          colors: [DateEmber.raised, DateEmber.surface, DateEmber.base],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Islamic pattern wallpaper.
          const Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Image(
                  image: AssetImage('assets/images/islamic-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  color: DateEmber.ivory,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
          // Warm amber wash at the top.
          const Positioned(
            left: -120,
            right: -120,
            top: -120,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [Color(0x38E1A560), Color(0x00E1A560)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Rising ember sparks.
          const Positioned.fill(child: IgnorePointer(child: _EmberField())),
          // Foreground content.
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header.
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'leaderboard.eyebrow'.tr().toUpperCase(),
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: DateEmber.amber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'leaderboard.title'.tr(),
          style: const TextStyle(
            fontFamily: _serif,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            fontSize: 24,
            height: 1,
            letterSpacing: -0.3,
            color: DateEmber.ivory,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scope segmented control (Individuals / Teams).
// ─────────────────────────────────────────────────────────────────────────────
class _ScopeSegmented extends StatelessWidget {
  const _ScopeSegmented({required this.value, required this.onChanged});

  final RankingsScope value;
  final ValueChanged<RankingsScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x0AF4ECD8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DateEmber.hairline),
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
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x33F1C57A), Color(0x1FA6622A)],
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    scope.labelKey.tr().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: scope == value
                          ? DateEmber.amberLight
                          : DateEmber.txtMute,
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

// ─────────────────────────────────────────────────────────────────────────────
// Category filter (individuals only).
// ─────────────────────────────────────────────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap();
          // Bring the tapped chip fully into view (centre it).
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
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33F1C57A), Color(0x1FA6622A)],
                  )
                : null,
            color: selected ? null : const Color(0x0AF4ECD8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? DateEmber.glassBorder : DateEmber.hairline,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? DateEmber.amberLight : DateEmber.txtMute,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — loading / error / no-team / empty / list states.
// ─────────────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final RankingsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (state.activeStatus == RankingsStatus.loading && state.activeIsEmpty) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: DateEmber.amber,
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
          itemBuilder: (context, i) =>
              _RankRow(seed: _rowAt(state, i)),
        ),
        if (state.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: DateEmber.amber,
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

/// Shared view seed for podium pillars and ranking rows.
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

// ─────────────────────────────────────────────────────────────────────────────
// Podium.
// ─────────────────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  const _Podium({required this.seeds});

  final List<_RankSeed> seeds;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) {
      return const _EmptyHint(textKey: 'leaderboard.podium_empty', vertical: 28);
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
    final isFirst = place == 1;
    final accent = switch (place) {
      1 => DateEmber.amber,
      2 => DateEmber.silverMid,
      _ => DateEmber.emberLight,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    final pedTint = switch (place) {
      1 => DateEmber.amber,
      2 => DateEmber.silverMid,
      _ => DateEmber.ember,
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
              // Soft glow halo.
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
        Text(
          seed?.name ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? DateEmber.amberLight : DateEmber.ivory,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          seed == null ? '—' : '${seed!.completed}/${seed!.total}',
          style: TextStyle(
            fontFamily: _mono,
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: accent,
          ),
        ),
        const SizedBox(height: 7),
        // Pedestal.
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
          child: Text(
            place < 10 ? '0$place' : '$place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _mono,
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
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DateEmber.base,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$place',
        style: TextStyle(
          fontFamily: _mono,
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
          colors: [DateEmber.amberLight, DateEmber.amberDeep],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = DateEmber.bronzeLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Ranking rows.
// ─────────────────────────────────────────────────────────────────────────────
class _RankRow extends StatelessWidget {
  const _RankRow({required this.seed});

  final _RankSeed seed;

  @override
  Widget build(BuildContext context) {
    final isMe = seed.isMe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0x1FE1A560), Color(0x05E1A560)],
              )
            : null,
        color: isMe ? null : const Color(0x06F4ECD8),
        border: Border.all(
          color: isMe ? const Color(0x66E1A560) : const Color(0x0DF4ECD8),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              seed.rank.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _mono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? DateEmber.amber : DateEmber.txtFaint,
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
                Text(
                  isMe
                      ? 'leaderboard.name_you'.tr(namedArgs: {'name': seed.name})
                      : seed.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: isMe ? DateEmber.amberLight : DateEmber.ivory,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _metaLine(seed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: DateEmber.txtMute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${seed.completed}/${seed.total}',
                style: TextStyle(
                  fontFamily: _mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? DateEmber.amberLight : DateEmber.ivory,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${seed.percent}%',
                style: const TextStyle(
                  fontFamily: _mono,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: DateEmber.olive,
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

// ─────────────────────────────────────────────────────────────────────────────
// Footer — my-rank ember card.
// ─────────────────────────────────────────────────────────────────────────────
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
    final card = Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x2EC9512B), Color(0x147A2E15)],
        ),
        border: Border.all(color: const Color(0x66E07A48)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [DateEmber.emberLight, DateEmber.ember],
              ),
              boxShadow: [
                BoxShadow(
                  color: DateEmber.ember.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontFamily: _mono,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DateEmber.emberInk,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: _mono,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: DateEmber.amber,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: DateEmber.amberLight,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16, color: DateEmber.amber),
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty / error states.
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.textKey, this.vertical = 0});

  final String textKey;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Center(
        child: Text(
          textKey.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: DateEmber.txtMute,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'leaderboard.error'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: DateEmber.txtMute,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'common.retry'.tr(),
              style: const TextStyle(
                color: DateEmber.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Eyebrow rules (── PODIUM ──, ── ALL MEMBERS · n ──).
// ─────────────────────────────────────────────────────────────────────────────
class _EyebrowRule extends StatelessWidget {
  const _EyebrowRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _RuleSegment(toRight: true),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: DateEmber.amber,
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
    final line = Expanded(
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00E1A560), Color(0x4DE1A560), Color(0x00E1A560)],
          ),
        ),
      ),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 8),
        Text(
          'leaderboard.all_members'
              .tr(namedArgs: {'count': '$count'})
              .toUpperCase(),
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
            color: DateEmber.txtMute,
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
    return SizedBox(
      width: 26,
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: toRight
                ? const [Color(0x00E0A560), DateEmber.amber]
                : const [DateEmber.amber, Color(0x00E0A560)],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metallic disc avatars.
// ─────────────────────────────────────────────────────────────────────────────
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
        [DateEmber.goldHi, DateEmber.goldMid, DateEmber.goldLo],
        DateEmber.goldInk,
        const Color(0x8CE1A560),
      ),
      _DiscStyle.silver => (
        [DateEmber.silverHi, DateEmber.silverMid, DateEmber.silverLo],
        DateEmber.goldInk,
        const Color(0x80DCCDB4),
      ),
      _DiscStyle.bronze => (
        [DateEmber.bronzeHi, DateEmber.bronzeMid, DateEmber.bronzeLo],
        DateEmber.bronzeInk,
        const Color(0x80C9512B),
      ),
      _DiscStyle.olive => (
        [DateEmber.oliveHi, DateEmber.oliveMid, DateEmber.oliveLo],
        DateEmber.oliveInk,
        const Color(0x33E1A560),
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
      child: Text(
        initial,
        style: TextStyle(fontFamily: _serif, fontSize: fontSize, color: ink),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rising ember particle field.
// ─────────────────────────────────────────────────────────────────────────────
class _EmberField extends StatefulWidget {
  const _EmberField();

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
        painter: _EmberPainter(sparks: _sparks, t: _c.value),
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
  _EmberPainter({required this.sparks, required this.t});
  final List<_Spark> sparks;
  final double t;

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
            DateEmber.amberLight.withValues(alpha: opacity),
            DateEmber.emberLight.withValues(alpha: opacity * 0.6),
            DateEmber.emberLight.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
