import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../teams/presentation/widgets/team_disc.dart';

/// "My Team" summary strip shown on the home screen once the user has joined a
/// circle — the State B counterpart to [JoinTeamCard].
///
/// Ported from the *Zad · Date & Ember Home* design: a denser glass card with
/// the team crest, an ember **rank** badge, stacked member avatars, and a
/// companions count. Tapping it opens the full team space.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.teamName,
    required this.memberCount,
    this.rank,
    this.memberSeeds = const [],
    this.onTap,
  });

  /// Display name of the team (shown in Fraunces italic).
  final String teamName;

  /// Total companions in the team — drives the "+N" overflow and the footer.
  final int memberCount;

  /// Global rank of the team, when known. Renders the ember `#rank` badge.
  final int? rank;

  /// Seeds (usually usernames) for the stacked avatar discs.
  final List<String> memberSeeds;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.creamSurfaceTop, colors.creamSurfaceBottom],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: colors.accentDeep.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TopRow(
                teamName: teamName,
                memberCount: memberCount,
                rank: rank,
              ),
              const SizedBox(height: 14),
              _Footer(
                memberCount: memberCount,
                memberSeeds: memberSeeds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.teamName,
    required this.memberCount,
    required this.rank,
  });

  final String teamName;
  final int memberCount;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TeamDisc(seed: teamName, size: 50, borderColor: null),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.team.companions_count'.tr(args: ['$memberCount']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8.5 * 0.30,
                  color: colors.accentDeep,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyXLarge.copyWith(
                  color: colors.textArabic,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.3,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        if (rank != null) ...[
          const SizedBox(width: 10),
          _RankBadge(rank: rank!),
        ],
      ],
    );
  }
}

/// Ember-tinted rank pill — "#14 / RANK" — lifted from the design's `.rank`.
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ember.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emberBright.withValues(alpha: 0.32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$rank',
            style: AppTextStyles.bodyXLarge.copyWith(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1,
              color: AppColors.emberBright,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'home.team.rank_label'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: colors.dateSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.memberCount, required this.memberSeeds});

  final int memberCount;
  final List<String> memberSeeds;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.only(top: 13),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          _MemberStack(memberCount: memberCount, seeds: memberSeeds),
          const Spacer(),
          Text(
            'home.team.companions_count'.tr(args: ['$memberCount']),
            style: AppTextStyles.bodySmall.copyWith(color: colors.dateSoft),
          ),
        ],
      ),
    );
  }
}

/// Overlapping avatar discs with a trailing "+N" chip for the remainder.
class _MemberStack extends StatelessWidget {
  const _MemberStack({required this.memberCount, required this.seeds});

  final int memberCount;
  final List<String> seeds;

  static const _maxVisible = 4;
  static const _disc = 28.0;
  static const _step = 19.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = seeds.take(_maxVisible).toList();
    final overflow = memberCount - visible.length;

    // Nothing to show yet (avatars still loading) — keep the row height stable.
    if (visible.isEmpty) return const SizedBox(height: _disc);

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      children.add(
        Positioned(
          left: i * _step,
          child: TeamDisc(
            seed: visible[i],
            size: _disc,
            fontSize: 11,
            borderColor: colors.canvas,
            borderWidth: 2,
            useSerif: false,
          ),
        ),
      );
    }
    if (overflow > 0) {
      children.add(
        Positioned(
          left: visible.length * _step,
          child: Container(
            width: _disc,
            height: _disc,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.canvasRaised.withValues(alpha: 0.55),
              border: Border.all(color: colors.canvas, width: 2),
            ),
            child: Center(
              child: Text(
                '+$overflow',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final slots = visible.length + (overflow > 0 ? 1 : 0);
    return SizedBox(
      height: _disc,
      width: (slots - 1) * _step + _disc,
      child: Stack(children: children),
    );
  }
}
