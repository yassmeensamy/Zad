import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// The deep olive hero card — used on Team Home and Team Progress as the
/// primary identity / momentum surface. Amber radial wash at the top-right
/// and a subtle 1px amber inner border.
class OliveHeroCard extends StatelessWidget {
  const OliveHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xlAll,
        // Frosted ivory-glass over the Date & Ember backdrop in dark; the same
        // tokens resolve to the olive ramp in light, so this stays olive there.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
          colors: [
            colors.heroSurfaceTop,
            colors.heroSurfaceMid,
            colors.heroSurfaceBottom,
          ],
        ),
        border: Border.all(
          color: colors.heroGlow.withValues(alpha: 0.18),
        ),
        boxShadow: ZaadShadows.hero(colors),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Warm amber wash bleeding in from the top-right corner.
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.heroGlow.withValues(alpha: 0.30),
                    colors.heroGlow.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
