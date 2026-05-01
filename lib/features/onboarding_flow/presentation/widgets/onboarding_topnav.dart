import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';

// Mirrors automatically in RTL via [IconData.matchTextDirection].
const IconData _backChevron = IconData(
  0xf63a, // Icons.chevron_left_rounded
  fontFamily: 'MaterialIcons',
  matchTextDirection: true,
);

/// Top navigation row used across the onboarding flow: optional back button
/// at the start, and either the brand mini-mark or a step label centered.
/// A fixed trailing spacer keeps the centered content visually balanced.
class OnboardingTopNav extends StatelessWidget {
  const OnboardingTopNav({
    super.key,
    this.onBack,
    this.showBrand = false,
    this.stepLabel,
  });

  final VoidCallback? onBack;
  final bool showBrand;
  final String? stepLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: onBack != null
                ? ZaadAppBarIconButton(
                    icon: _backChevron,
                    iconSize: 20,
                    onTap: onBack!,
                  )
                : null,
          ),
          Expanded(
            child: Center(
              child: showBrand
                  ? const _MiniMark()
                  : stepLabel != null
                  ? ResponsiveText(
                      stepLabel!,
                      style: ZaadType.eyebrow.copyWith(color: colors.oliveSoft),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 38, height: 38),
        ],
      ),
    );
  }
}

class _MiniMark extends StatelessWidget {
  const _MiniMark();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.olive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.oliveDeep,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ResponsiveText(
          'Zaad',
          style: AppTextStyles.titleLarge.copyWith(
            color: colors.oliveDeep,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
