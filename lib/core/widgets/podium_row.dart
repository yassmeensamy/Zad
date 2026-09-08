import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'medal_disc.dart';
import 'rank_crown.dart';
import 'responsive_text.dart';

/// One finisher on a [PodiumRow].
///
/// Screens map their own model onto this — the podium itself knows nothing
/// about rankings, teams or members.
class PodiumEntry {
  const PodiumEntry({
    required this.initial,
    required this.name,
    required this.caption,
    this.flag,
    this.noteIcon,
    this.note,
  });

  /// Single glyph shown in the medal disc. See [discInitial].
  final String initial;
  final String name;

  /// The line under the name — whatever the screen ranks by (a level count,
  /// a score), already formatted.
  final String caption;

  /// Flag emoji shown before the name; omitted when null or empty.
  final String? flag;

  /// Optional secondary stat under [caption] — both must be set to show it.
  final IconData? noteIcon;
  final String? note;
}

/// Top-three podium: 2nd — 1st (raised) — 3rd, each on a gold/silver/bronze
/// pedestal.
///
/// Shared by the leaderboard podium and the team home podium; see [RankCrown],
/// which the same pair already shares.
class PodiumRow extends StatelessWidget {
  const PodiumRow({super.key, required this.places});

  /// First, second and third place in that order. Short lists and null slots
  /// both render as an empty pillar, so a podium with two finishers keeps its
  /// shape instead of collapsing.
  final List<PodiumEntry?> places;

  @override
  Widget build(BuildContext context) {
    PodiumEntry? at(int i) => i < places.length ? places[i] : null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 100, child: _PodiumPillar(place: 2, entry: at(1))),
          const SizedBox(width: 9),
          Expanded(flex: 115, child: _PodiumPillar(place: 1, entry: at(0))),
          const SizedBox(width: 9),
          Expanded(flex: 100, child: _PodiumPillar(place: 3, entry: at(2))),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({required this.place, required this.entry});

  final int place;
  final PodiumEntry? entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isFirst = place == 1;
    // One medal tint per place, carrying the disc glow, the badge, the caption
    // and the pedestal alike.
    final accent = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.discBronzeMid,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    // Everything the pillar *writes* — caption, badge digit, pedestal number —
    // inks in the medal tint, except silver, which is a pale cream that reads
    // as barely-there on the light canvas and as a glare on the night one. The
    // metal itself (glow, ring, pedestal wash) keeps the medal tint either way.
    final ink = place == 2
        ? (context.isDark
              ? AppColors.discSilverInkDark
              : AppColors.discSilverInk)
        : accent;
    final avatarSize = isFirst ? 62.0 : 52.0;
    // The winner's name is the one warm-on-warm label on the pillar, so it
    // takes the same split the ranking rows use: the soft amber holds up on
    // the night canvas but sits near 2.8:1 on the cream one, which drops to
    // the deeper amber instead.
    final winnerInk = context.isDark ? colors.accentSoft : colors.accentDeep;

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
              MedalDisc(
                size: avatarSize,
                initial: entry?.initial ?? '?',
                style: discStyleForPlace(place),
                fontSize: isFirst ? 24 : 20,
              ),
              if (isFirst && entry != null)
                const Positioned(top: -8, child: RankCrown()),
              Positioned(
                right: 2,
                bottom: 2,
                child: _PodiumBadge(place: place, color: accent, ink: ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (entry?.flag case final flag? when flag.isNotEmpty) ...[
              ResponsiveText(
                flag,
                style: AppTextStyles.labelMedium.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: ResponsiveText(
                entry?.name ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
                  color: isFirst ? winnerInk : colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          entry?.caption ?? '—',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: ink,
          ),
        ),
        if ((entry?.noteIcon, entry?.note) case (final icon?, final note?)) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isFirst ? 11 : 10, color: accent),
              const SizedBox(width: 3),
              ResponsiveText(
                note,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: isFirst ? 11 : 10,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 7),
        Container(
          height: pedHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(
              top: BorderSide(color: accent.withValues(alpha: 0.4)),
              left: BorderSide(color: accent.withValues(alpha: 0.4)),
              right: BorderSide(color: accent.withValues(alpha: 0.4)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: ResponsiveText(
            '0$place',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumBadge extends StatelessWidget {
  const _PodiumBadge({
    required this.place,
    required this.color,
    required this.ink,
  });

  /// The medal tint — the ring stays metal even where [ink] darkens the digit.
  final Color color;
  final Color ink;
  final int place;

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
          color: ink,
        ),
      ),
    );
  }
}
