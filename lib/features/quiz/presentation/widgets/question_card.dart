import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/question_model.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xxlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colors.canvasRaised, Colors.white, 0.06) ??
                colors.canvasRaised,
            colors.canvasRaised,
            Color.lerp(colors.canvas, colors.olive, 0.06) ?? colors.canvas,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: ZaadRadii.xxlAll,
        child: Stack(
          children: [
            PositionedDirectional(
              end: -28,
              top: -28,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.olive.withValues(alpha: 0.10),
                        colors.olive.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.olive,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'quiz.question_eyebrow'.tr(),
                        style: ZaadType.eyebrowSm.copyWith(color: colors.olive),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.olive.withValues(alpha: 0.14),
                              colors.olive.withValues(alpha: 0.04),
                            ],
                          ),
                          border: Border.all(
                            color: colors.olive.withValues(alpha: 0.18),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: colors.olive.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 28,
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          colors.olive.withValues(alpha: 0.55),
                          colors.olive.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    question.text,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.55,
                      letterSpacing: 0.1,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
