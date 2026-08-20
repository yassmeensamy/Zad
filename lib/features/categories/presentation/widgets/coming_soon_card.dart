import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_links.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/star_medallion.dart';
import '../../../../theme/theme.dart';
import 'coming_soon_motifs.dart';

/// Trailing tile in the categories grid: announces that more categories are on
/// the way and invites the user to share the app.
///
/// Built as a veil rather than as a card. Underneath sits the silhouette of a
/// category that doesn't exist yet — rosette, orbs, progress bar — and a
/// [BackdropFilter] frosts it into soft blooms, so the tile *shows* that
/// something is behind it without showing what. The label, motifs and call to
/// action ride crisp on top of the frost.
///
/// That is also why it doesn't use [AppCard]: every other card in the grid is
/// one flat surface, and this one needs a real layer stack (ghost → blur →
/// frost → content) to read as a different kind of tile at a glance.
///
/// Sized for the grid cell it shares with the category cards (240 max wide,
/// 220 tall); on a 360dp phone that cell is only ~152px across, so every band
/// is sized for the narrow case.
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key});

  Future<void> _share(BuildContext context) async {
    // Both store links go out every time: the share sheet has no idea what the
    // recipient is holding, so whoever gets the message picks their own.
    await sl<ShareService>().shareFrom(
      context: context,
      text: 'categories.coming_soon.share_message'.tr(
        namedArgs: {
          'app': 'app_name'.tr(),
          'ios': AppLinks.appStore,
          'android': AppLinks.playStore,
        },
      ),
      subject: 'categories.coming_soon.share_subject'.tr(
        namedArgs: {'app': 'app_name'.tr()},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = colors.accent;

    return DecoratedBox(
      // Lift matches the elevated category cards so the tile still sits on the
      // same plane as its neighbours.
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xxlAll,
        boxShadow: ZaadShadows.elevated(colors, tint: tint),
      ),
      child: ClipRRect(
        borderRadius: ZaadRadii.xxlAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _GhostLayer(),
            _Frost(tint: tint),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _share(context),
                splashColor: tint.withValues(alpha: 0.10),
                highlightColor: tint.withValues(alpha: 0.05),
                child: _Content(tint: tint),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DashedRRectBorderPainter(
                    color: tint.withValues(alpha: 0.45),
                    radius: ZaadRadii.xxl,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layer 1 — what the blur is blurring. Never seen sharp.
class _GhostLayer extends StatelessWidget {
  const _GhostLayer();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvasRaised,
            Color.lerp(colors.canvas, colors.accent, 0.10)!,
          ],
        ),
      ),
      child: CustomPaint(
        painter: GhostBloomPainter(
          tint: colors.accent.withValues(alpha: 0.55),
          warm: colors.olive.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}

/// Layer 2 — the veil. The blur softens the ghost beneath; the translucent
/// wash on top of it holds contrast for the copy so the text never has to
/// fight the bloom behind it.
class _Frost extends StatelessWidget {
  const _Frost({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Light enough that the bloom behind still shows through — at the
            // opacity a normal card surface uses, the blur was invisible and
            // the tile just looked flat.
            colors: [
              colors.canvasRaised.withValues(alpha: 0.42),
              colors.canvasRaised.withValues(alpha: 0.74),
            ],
          ),
          // Inner hairline, catching the light along the top edge the way
          // frosted glass does.
          border: Border(
            top: BorderSide(color: tint.withValues(alpha: 0.22), width: 1),
          ),
        ),
      ),
    );
  }
}

/// Layer 3 — everything the user actually reads, crisp on the frost.
class _Content extends StatelessWidget {
  const _Content({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LabelChip(tint: tint),
          const SizedBox(height: 12),
          _WaitingMedallion(tint: tint),
          const SizedBox(height: 12),
          Flexible(child: _Pitch(tint: tint)),
        ],
      ),
    );
  }
}

/// The label, above the icon. A floating chip rather than a bar — on frosted
/// glass a solid band would read as a second surface.
class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: ZaadRadii.pillAll,
        border: Border.all(color: tint.withValues(alpha: 0.38), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 9,
            height: 9,
            child: CustomPaint(
              painter: KhatimStarPainter(
                fill: tint.withValues(alpha: 0.35),
                stroke: tint,
                strokeWidth: 0.7,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Scales down rather than wrapping — the label holds one line at any
          // card width, in either language.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ResponsiveText(
                'categories.coming_soon.title',
                maxLines: 1,
                style: ZaadType.eyebrow.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: colors.accentDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The icon, under the label. One hourglass in a khatim frame — the point is
/// that it should say "not yet, but soon" on sight. The star frame is the same
/// medallion the category cards use, so the tile still belongs to the set even
/// though its glyph is the odd one out.
class _WaitingMedallion extends StatelessWidget {
  const _WaitingMedallion({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return StarMedallion(
      size: 52,
      tint: tint,
      strokeWidth: 1,
      child: Icon(
        Icons.hourglass_top_rounded,
        size: 24,
        color: colors.accentDeep,
      ),
    );
  }
}

/// The ask, and the call to action.
class _Pitch extends StatelessWidget {
  const _Pitch({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const fontSize = 11.0;
    const lineSpacing = 1.35;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          // The grid cell's height is pinned, but type scales with the app's
          // text scaler — so a fixed maxLines would overflow the cell at large
          // scales. Derive the line count from the height actually left over
          // instead, and let the copy ellipsize.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final lineHeight =
                  MediaQuery.textScalerOf(context).scale(fontSize) * lineSpacing;
              final lines = (constraints.maxHeight / lineHeight)
                  .floor()
                  .clamp(1, 3);
              return ResponsiveText(
                'categories.coming_soon.subtitle',
                textAlign: TextAlign.center,
                maxLines: lines,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: fontSize,
                  letterSpacing: 0,
                  height: lineSpacing,
                  color: colors.textSecondary,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _SharePill(tint: tint),
      ],
    );
  }
}

/// Not a button — the whole card is the tap target — so it has to look
/// pressable without stealing the card's [InkWell].
class _SharePill extends StatelessWidget {
  const _SharePill({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: ZaadRadii.pillAll,
        border: Border.all(color: tint.withValues(alpha: 0.42), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ios_share_rounded, size: 12, color: colors.accentDeep),
          const SizedBox(width: 6),
          Flexible(
            child: ResponsiveText(
              'categories.coming_soon.cta',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: colors.accentDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
