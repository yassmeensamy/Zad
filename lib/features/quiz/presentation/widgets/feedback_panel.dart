import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.isCorrect,
    this.motivationalKey,
    this.explanation,
    this.reference,
  });

  final bool isCorrect;
  final String? motivationalKey;
  final String? explanation;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = isCorrect ? colors.olive : context.colorScheme.error;
    final eyebrowKey = isCorrect
        ? 'quiz.feedback.correct_eyebrow'
        : 'quiz.feedback.incorrect_eyebrow';

    return TweenAnimationBuilder<double>(
      key: ValueKey('feedback-${isCorrect ? 'correct' : 'wrong'}-$motivationalKey'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: Color.lerp(colors.canvasRaised, accent, 0.06),
          borderRadius: ZaadRadii.xlAll,
          border: Border.all(
            color: accent.withValues(alpha: 0.30),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.auto_awesome_rounded
                      : Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 8),
                ResponsiveText(
                  eyebrowKey,
                  style: ZaadType.eyebrowSm.copyWith(color: accent),
                ),
              ],
            ),
            if (isCorrect && motivationalKey != null) ...[
              const SizedBox(height: 10),
              ResponsiveText(
                motivationalKey,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: colors.textPrimary,
                ),
              ),
            ],
            if (explanation != null && explanation!.isNotEmpty) ...[
              const SizedBox(height: 14),
              ResponsiveText(
                'quiz.feedback.explanation',
                style: ZaadType.eyebrowSm.copyWith(
                  color: colors.textTertiary,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 6),
              ResponsiveText(
                explanation,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  height: 1.7,
                  color: colors.textSecondary,
                ),
              ),
            ],
            if (reference != null && reference!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 12,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: ResponsiveText(
                      reference,
                      style: ZaadType.captionSmall.copyWith(
                        fontSize: 11,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
