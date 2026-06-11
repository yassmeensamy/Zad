// The joined-team summary card shown on the home screen once the user belongs
// to a team: team crest + name, member count, leaderboard rank chip, stacked
// member avatars and the team's overall completion. Purely presentational —
// all data is passed in from [TeamsCubit] via [HomeTeamSection]; no mock data.
//
// Fully theme-driven: every colour comes from `context.appColors` so it reads
// as warm cream/gold in light and roasted brown/amber in dark, and all type
// uses [AppTextStyles] with the app's default font (ElMessiri).
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../data/models/team_member_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_progress_summary_model.dart';
import '../../../../theme/theme.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team, this.members, this.summary});

  /// The user's team (name, member count) — always available in this state.
  final TeamModel team;

  /// Roster, loaded asynchronously. Drives the stacked avatars; null/empty
  /// while it is still in flight (the overflow chip covers the gap).
  final List<TeamMemberModel>? members;

  /// Leaderboard standing + per-member progress, loaded asynchronously. Drives
  /// the rank chip and the overall-completion line; both hide while null.
  final TeamProgressSummaryModel? summary;

  static const double _avatarSize = 28;
  static const double _avatarStep = 19;
  static const int _maxAvatars = 3;

  // Decorative avatar identities (gradient + letter ink), cycled per member.
  // Mid-tone so they read on both the cream and brown card surfaces.
  static const List<(List<Color>, Color)> _avatarPalettes = [
    ([AppColors.amberLight, AppColors.discGoldLo], AppColors.discGoldInk),
    ([AppColors.discOliveHi, AppColors.discOliveLo], AppColors.discOliveInk),
    ([AppColors.discBronzeHi, AppColors.discBronzeLo], AppColors.discBronzeInk),
  ];

  /// First visible character of [s] (works for Latin and Arabic names).
  String _firstGlyph(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCode(t.runes.first).toUpperCase();
  }

  /// Overall team completion across all members, or null until [summary] loads.
  int? _teamPercent() {
    final s = summary;
    if (s == null) return null;
    final total = s.members.fold<int>(0, (a, m) => a + m.totalLevels);
    if (total <= 0) return 0;
    final done = s.members.fold<int>(0, (a, m) => a + m.completedLevels);
    return (done / total * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TeamCardShell(
      child: Column(
        children: [
          _header(colors),
          const SizedBox(height: 14),
          Container(height: 1, color: colors.borderSubtle),
          const SizedBox(height: 13),
          _footer(colors),
        ],
      ),
    );
  }

  Widget _header(AppColorsTheme colors) {
    final rank = summary?.teamRank;
    return Row(
      children: [
        // Team crest disc with the first glyph of the team name.
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: BrandGradients.crest([
              colors.goldLight,
              colors.accent,
              colors.accentDeep,
            ]),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.45),
                spreadRadius: 1.5,
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: ResponsiveText(
            _firstGlyph(team.name),
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 22,
              height: 1,
              color: colors.goldInk,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                'home.team.companions_count',
                args: [team.memberCount.toString()],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 18,
                  height: 1.05,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (rank != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.accent.withValues(alpha: 0.14),
              border: Border.all(color: colors.accent.withValues(alpha: 0.34)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText(
                  '#$rank',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 18,
                    height: 1,
                    color: colors.accentDeep,
                  ),
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  'home.team.rank_label',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _footer(AppColorsTheme colors) {
    final shown = (members ?? const <TeamMemberModel>[])
        .take(_maxAvatars)
        .toList();
    final remaining = team.memberCount - shown.length;
    final hasOverflow = remaining > 0;
    final slots = shown.length + (hasOverflow ? 1 : 0);
    final stackWidth = slots == 0
        ? 0.0
        : (slots - 1) * _avatarStep + _avatarSize;
    final percent = _teamPercent();

    return Row(
      children: [
        // Stacked member avatars + overflow chip for the rest of the roster.
        SizedBox(
          width: stackWidth,
          height: _avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < shown.length; i++)
                _memberAvatar(colors, i, shown[i].username),
              if (hasOverflow)
                Positioned(
                  left: shown.length * _avatarStep,
                  child: Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accent.withValues(alpha: 0.12),
                      border: Border.all(
                        color: colors.creamSurfaceTop,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: ResponsiveText(
                      '+$remaining',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        if (percent != null)
          ResponsiveText(
            'categories.progress.percent',
            args: [percent.toString()],
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: colors.success,
            ),
          ),
      ],
    );
  }

  Widget _memberAvatar(AppColorsTheme colors, int index, String username) {
    final (gradient, ink) = _avatarPalettes[index % _avatarPalettes.length];
    return Positioned(
      left: index * _avatarStep,
      child: Container(
        width: _avatarSize,
        height: _avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: BrandGradients.crest(gradient),
          border: Border.all(color: colors.creamSurfaceTop, width: 2),
        ),
        alignment: Alignment.center,
        child: ResponsiveText(
          _firstGlyph(username),
          style: AppTextStyles.labelMedium.copyWith(fontSize: 11, color: ink),
        ),
      ),
    );
  }
}

/// Shared surface for the home team cards (join + summary): a cream→brown
/// gradient with an amber hairline border, a grounding drop shadow, a warm
/// amber lift, and a clipped radial halo for depth. Every colour is a semantic
/// token so it reads as warm cream in light and roasted brown in dark.
class TeamCardShell extends StatelessWidget {
  const TeamCardShell({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(16),
    this.haloCenter = const Alignment(-1, -1),
    this.haloRadius = 1.2,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  /// Origin and reach of the warm halo. The join card centres it above the
  /// crest; the summary card glows from the top-left corner.
  final Alignment haloCenter;
  final double haloRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final border = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: border,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.creamSurfaceTop, colors.creamSurfaceBottom],
        ),
        border: Border.all(color: colors.accent.withValues(alpha: 0.24)),
        boxShadow: [
          // Grounding drop shadow.
          BoxShadow(
            color: colors.heroShadow.withValues(alpha: 0.20),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
          // Warm amber lift so the card glows off the page in both themes.
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: DecoratedBox(
          // A soft amber halo for depth — also keeps the dark surface (where the
          // two cream tokens collapse to one flat brown) from reading as a slab.
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: haloCenter,
              radius: haloRadius,
              colors: [
                colors.accentSoft.withValues(alpha: 0.20),
                colors.accentSoft.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
