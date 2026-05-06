import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../cubit/levels_state.dart';

class LevelsHero extends StatelessWidget {
  const LevelsHero({
    super.key,
    required this.state,
    required this.tint,
    this.category,
  });

  final LevelsState state;
  final Color tint;
  final CategoryModel? category;

  String? get _iconUrl => category?.iconUrl;
  int? get _fallbackTotal => category?.levelCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final completed = state.completedCount;
    final total = state.totalCount == 0
        ? (_fallbackTotal ?? 0)
        : state.totalCount;
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.xxlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvasRaised,
            Color.lerp(colors.canvas, tint, 0.07)!,
          ],
        ),
        border: Border.all(color: tint.withValues(alpha: 0.22), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: ZaadRadii.xxlAll,
        child: Stack(
          children: [
            IslamicPatternCorner(
              color: tint,
              size: 100,
              tile: 20,
              opacity: 0.16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
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
                          if (_iconUrl != null && _iconUrl!.isNotEmpty)
                            ClipOval(
                              child: Image.network(
                                _iconUrl!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.menu_book_outlined,
                                  size: 24,
                                  color: tint,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.menu_book_outlined,
                              size: 24,
                              color: tint,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            'levels.eyebrow',
                            style: ZaadType.eyebrowSm.copyWith(color: tint),
                          ),
                          const SizedBox(height: 4),
                          ResponsiveText(
                            'levels.heading'.tr(args: [
                              '$completed',
                              '$total',
                            ]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: tint.withValues(alpha: 0.12),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 8,
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
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ResponsiveText(
                      'levels.percent'.tr(args: ['$percent']),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        color: tint,
                      ),
                    ),
                    const Spacer(),
                    ResponsiveText(
                      'levels.count'.tr(args: ['$completed', '$total']),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
