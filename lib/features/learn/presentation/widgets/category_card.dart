import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/learn_category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.tint,
    required this.onTap,
  });

  final LearnCategory category;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = category.progress;
    final percent = category.progressPercent;
    final isStarted = progress > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ZaadRadii.xxlAll,
        splashColor: tint.withValues(alpha: 0.10),
        highlightColor: tint.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: ZaadRadii.xxlAll,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.canvasRaised,
                Color.lerp(colors.canvas, tint, 0.06)!,
              ],
            ),
            border: Border.all(
              color: tint.withValues(alpha: 0.20),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.oliveDeep.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: tint.withValues(alpha: 0.04),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: ZaadRadii.xxlAll,
            child: Stack(
              children: [
                IslamicPatternCorner(
                  color: tint,
                  size: 130,
                  tile: 22,
                  opacity: 0.18,
                ),
                Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconMedallion(tint: tint, icon: category.icon),
                    const Spacer(),
                    ResponsiveText(
                      category.titleKey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.2,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      category.subtitleKey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 11.5,
                        letterSpacing: 0,
                        height: 1.35,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProgressBar(progress: progress, tint: tint),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              isStarted
                                  ? 'learn.progress.percent'
                                      .tr(args: ['$percent'])
                                  : 'learn.progress.not_started'.tr(),
                              maxLines: 1,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: tint,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              'learn.progress.levels'.tr(args: [
                                '${category.completedLevels}',
                                '${category.totalLevels}',
                              ]),
                              maxLines: 1,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconMedallion extends StatelessWidget {
  const _IconMedallion({required this.tint, required this.icon});

  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: KhatimStarPainter(
                fill: tint.withValues(alpha: 0.10),
                stroke: tint.withValues(alpha: 0.55),
                strokeWidth: 0.9,
              ),
            ),
          ),
          Icon(icon, size: 22, color: tint),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.tint});

  final double progress;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Stack(
        children: [
          Container(
            height: 6,
            color: tint.withValues(alpha: 0.12),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(tint, colors.accent, 0.25)!,
                    tint,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
