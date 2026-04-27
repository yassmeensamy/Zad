import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Top navigation row used across the onboarding flow:
/// optional back button on the left, optional brand mini-mark in the middle,
/// optional step label on the right (or a spacer to preserve layout).
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: onBack == null
                ? const SizedBox.shrink()
                : Material(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onBack,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: colors.oliveDeep,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Center(
              child: showBrand
                  ? const _MiniMark()
                  : (stepLabel != null
                      ? ResponsiveText(
                          stepLabel!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 10 * 0.32,
                            color: colors.oliveSoft,
                          ),
                        )
                      : const SizedBox.shrink()),
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
            alignment: Alignment.center,
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
                angle: 0.7853981633974483, // 45deg
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
          'Zad',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: colors.oliveDeep,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
