import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/level_model.dart';
import '../utils/level_status_styles.dart';
import 'level_status_chip.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locked = level.isLocked;

    final borderColor = level.status.tileBorder(colors, tint);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: locked
            ? null
            : () => context.pushNamed(
                  AppRoutes.quizName,
                  pathParameters: {'levelId': level.id.toString()},
                  extra: level,
                ),
        borderRadius: ZaadRadii.xlAll,
        splashColor: tint.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: locked
                ? colors.canvasRaised.withValues(alpha: 0.55)
                : colors.canvasRaised,
            borderRadius: ZaadRadii.xlAll,
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
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
                            level.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.1,
                              color: locked
                                  ? colors.textTertiary
                                  : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ResponsiveText(
                            'levels.questions'.tr(args: [
                              '${level.completedQuestions}',
                              '${level.questionCount}',
                            ]),
                            style: AppTextStyles.labelMedium.copyWith(
                              letterSpacing: 0,
                              color: locked
                                  ? colors.textPlaceholder
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    LevelStatusChip(level: level, tint: tint),
                  ],
                ),
                if (level.questionCount > 0 && !locked) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    child: Stack(
                      children: [
                        Container(
                          height: 5,
                          color: tint.withValues(alpha: 0.12),
                        ),
                        FractionallySizedBox(
                          widthFactor: level.progress,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: tint,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ResponsiveText(
                        'levels.percent'.tr(args: ['${level.progressPercent}']),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tint,
                        ),
                      ),
                      const Spacer(),
                      if (level.passingGrade > 0)
                        ResponsiveText(
                          'levels.pass'.tr(args: ['${level.passingGrade}']),
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
