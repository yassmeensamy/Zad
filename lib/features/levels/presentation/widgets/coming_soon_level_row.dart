import 'package:flutter/material.dart';

import '../../../../core/utils/share_app.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/eight_point_star.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';

/// Trailing stop on the levels timeline: the rest of the category's levels
/// aren't published yet, so the rail ends on a provisional row instead of just
/// running out.
///
/// Deliberately built from the levels screen's own parts rather than as a
/// special-looking tile — [AppCard], the badge and chip palettes the real rows
/// use, [ZaadPrimaryButton] — so it reads as the next row on the rail. Every
/// colour resolves from [AppColorsTheme] and the category [tint], so it follows
/// light/dark and the category's identity colour like everything above it.
class ComingSoonLevelRow extends StatelessWidget {
  const ComingSoonLevelRow({super.key, required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Same Stack-not-IntrinsicHeight trick as the real rows: the Row sizes the
    // stack and the connector stretches to fill it.
    return Stack(
      children: [
        PositionedDirectional(
          start: 21,
          top: 0,
          // This row is always last, so the rail stops short of the bottom the
          // way a final level's does.
          bottom: 28,
          child: Container(width: 2, color: colors.borderSubtle),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1,
                  child: _SoonBadge(tint: tint),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ComingSoonCard(tint: tint),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Stands in for `LevelBadge` on the rail, borrowing the palette an unlocked
/// level's badge uses — canvas fill, tinted ring, tinted glyph — because this
/// row is actionable too, just not a quiz. An ellipsis rather than the card's
/// hourglass: on the rail it has to say "the list keeps going", and repeating
/// one glyph twice in a row would read as a mistake.
class _SoonBadge extends StatelessWidget {
  const _SoonBadge({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.canvas,
        border: Border.all(color: tint, width: 1.4),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.more_horiz_rounded, size: 18, color: tint),
    );
  }
}

/// The row's card — the screen's closing statement, so it is built on the same
/// recipe as `LevelsHero` that opens it: [AppCard.elevated]'s tinted gradient
/// and two-layer lift, with a faint khatim ornament bleeding off the top-start
/// corner exactly where the hero puts its own.
///
/// That deliberately gives it more presence than the flat `canvasRaised` level
/// cards it follows, which is the point — it isn't a level, and the extra
/// weight is what earns it the CTA. It keeps their `ZaadRadii.xl` corner and
/// 16dp start padding, though, so it still sits in the column's rhythm rather
/// than floating free of it. Content mirrors `LevelCard`'s structure: title and
/// sub-line on the start side, status chip on the end.
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppCard.elevated(
      tint: tint,
      radius: ZaadRadii.xl,
      // Zeroed so the ornament can bleed to the card's edges; the content
      // carries its own padding below. AppCard clips to the radius, so the
      // overhang is trimmed by the corner rather than escaping the card.
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          PositionedDirectional(
            top: -30,
            start: -28,
            child: IgnorePointer(
              // Directional, unlike the hero's fixed-left vector, so the
              // ornament mirrors to the other corner in Arabic instead of
              // landing under the copy.
              child: EightPointStar(
                size: 112,
                color: tint,
                opacity: 0.09,
                strokeWidth: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                            'levels.coming_soon.title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.1,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ResponsiveText(
                            'levels.coming_soon.subtitle',
                            style: AppTextStyles.labelMedium.copyWith(
                              letterSpacing: 0,
                              height: 1.35,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SoonChip(tint: tint),
                  ],
                ),
                const SizedBox(height: 14),
                // The screen's own punctuation between copy and action —
                // the same rule that separates the hero from the timeline,
                // echoed once at the bottom to close the page.
                StarRule(color: tint, starSize: 9),
                const SizedBox(height: 14),
                ZaadPrimaryButton(
                  label: 'levels.coming_soon.cta',
                  onTap: () => shareApp(context),
                  variant: ZaadButtonVariant.accent,
                  leadingIcon: Icons.ios_share_rounded,
                  height: 42,
                  fontSize: 13,
                  iconSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors `LevelStatusChip` — same pill, same metrics, same `labelSmall`
/// treatment — with one more entry in that vocabulary: "soon".
class _SoonChip extends StatelessWidget {
  const _SoonChip({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: ZaadRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 12, color: tint),
          const SizedBox(width: 4),
          ResponsiveText(
            'levels.coming_soon.chip',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
