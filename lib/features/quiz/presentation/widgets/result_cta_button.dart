import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class ResultCtaButton extends StatelessWidget {
  const ResultCtaButton({super.key, required this.onTap, this.label});

  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final cta = CustomButton.full(
      onTap: onTap,
      theme: CustomButtonTheme(
        height: 58,
        borderRadius: 16,
        backgroundColor: colors.oliveDeep,
        textColor: colors.canvas,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResponsiveText(
            label ?? 'quiz.result.done',
            style: AppTextStyles.labelLarge.copyWith(color: colors.canvas),
          ),
        ],
      ),
    );

    return cta
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          delay: 1500.ms,
          duration: 1100.ms,
          color: colors.accent.withValues(alpha: 0.18),
        );
  }
}
