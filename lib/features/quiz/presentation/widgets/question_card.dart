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
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xxlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvasRaised,
            Color.lerp(colors.canvas, colors.olive, 0.05)!,
          ],
        ),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quiz.question_eyebrow'.tr(),
            style: ZaadType.eyebrowSm.copyWith(color: colors.olive),
          ),
          const SizedBox(height: 12),
          Text(
            question.text,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.55,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
