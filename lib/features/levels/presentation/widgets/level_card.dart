import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/gradient_progress_bar.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/level_model.dart';
import '../cubit/levels_cubit.dart';
import '../cubit/levels_state.dart';
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
                            'levels.questions'.tr(
                              args: [
                                '${level.completedQuestions}',
                                '${level.questionCount}',
                              ],
                            ),
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
                    if (!locked && (level.isCompleted || level.progress > 0))
                      _LevelResetButton(level: level),
                  ],
                ),
                if (level.questionCount > 0 && !locked) ...[
                  const SizedBox(height: 12),
                  GradientProgressBar(
                    progress: level.progress,
                    trackColor: tint.withValues(alpha: 0.12),
                    gradientColors: [tint, tint],
                    height: 5,
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

/// Small "reset progress" affordance shown on completed / in-progress
/// level cards. Reads [LevelsCubit] from the surrounding screen, confirms
/// with the user, then triggers [LevelsCubit.resetLevel]. Swaps to a
/// spinner while that level's reset is in flight.
class _LevelResetButton extends StatelessWidget {
  const _LevelResetButton({required this.level});

  final LevelModel level;

  Future<void> _confirmReset(BuildContext context) async {
    final cubit = context.read<LevelsCubit>();
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: Icons.restart_alt_rounded,
      titleKey: 'levels.reset.confirm_title',
      messageKey: 'levels.reset.confirm_subtitle',
      confirmKey: 'levels.reset.confirm_cta',
    );
    if (confirmed != true) return;
    await cubit.resetLevel(level.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final isResetting = context.select<LevelsCubit, bool>(
      (c) => c.state.isResetting(level.id),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: isResetting
          ? SizedBox(
              width: 32,
              height: 32,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: errorColor,
                ),
              ),
            )
          : IconButton(
              onPressed: () => _confirmReset(context),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'levels.reset.action'.tr(),
              icon: Icon(
                Icons.restart_alt_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
            ),
    );
  }
}
