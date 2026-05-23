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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xlAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
          colors: [
            AppColors.olive,
            AppColors.oliveDeep,
            AppColors.oliveAbyss,
          ],
        ),
        border: Border.all(
          color: AppColors.amberGlow.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
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
                    AppColors.amberGlow.withValues(alpha: 0.30),
                    AppColors.amberGlow.withValues(alpha: 0),
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
