import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/gradient_progress_bar.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/star_medallion.dart';
import '../../../../theme/theme.dart';
import '../../data/models/category_model.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.tint,
    required this.onTap,
  });

  final CategoryModel category;
  final Color tint;
  final VoidCallback? onTap;

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
            border: Border.all(color: tint.withValues(alpha: 0.20), width: 0.8),
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
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    AppImages.vector,
                    width: 200,
                    cacheWidth: 400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconMedallion(tint: tint, iconUrl: category.iconUrl),
                      const Spacer(),
                      ResponsiveText(
                        category.name,
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
                        category.description,
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
                      GradientProgressBar(
                        progress: progress,
                        trackColor: tint.withValues(alpha: 0.12),
                        gradientColors: [
                          Color.lerp(tint, colors.accent, 0.25)!,
                          tint,
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                isStarted
                                    ? 'categories.progress.percent'.tr(
                                        args: ['$percent'],
                                      )
                                    : 'categories.progress.not_started'.tr(),
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
                                'categories.progress.levels'.tr(
                                  args: [
                                    '${category.completedLevels}',
                                    '${category.levelCount}',
                                  ],
                                ),
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
                if (isStarted)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: _CategoryResetButton(category: category),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "reset progress" affordance on started category cards. Reads
/// [CategoriesCubit] from the surrounding screen, confirms with the user,
/// then triggers [CategoriesCubit.resetCategory]. Swaps to a spinner while
/// that category's reset is in flight.
class _CategoryResetButton extends StatelessWidget {
  const _CategoryResetButton({required this.category});

  final CategoryModel category;

  Future<void> _confirmReset(BuildContext context) async {
    final cubit = context.read<CategoriesCubit>();
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: Icons.restart_alt_rounded,
      titleKey: 'categories.reset.confirm_title',
      messageKey: 'categories.reset.confirm_subtitle',
      confirmKey: 'categories.reset.confirm_cta',
    );
    if (confirmed != true) return;
    await cubit.resetCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final isResetting = context.select<CategoriesCubit, bool>(
      (c) => c.state.isResetting(category.id),
    );

    return Material(
      color: colors.canvas.withValues(alpha: 0.85),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      clipBehavior: Clip.antiAlias,
      child: isResetting
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : InkWell(
              onTap: () => _confirmReset(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: ResponsiveText(
                  'common.reset',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: errorColor,
                  ),
                ),
              ),
            ),
    );
  }
}

class _IconMedallion extends StatelessWidget {
  const _IconMedallion({required this.tint, required this.iconUrl});

  final Color tint;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return StarMedallion(
      size: 48,
      tint: tint,
      child: iconUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                iconUrl,
                width: 22,
                height: 22,
                cacheWidth: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.menu_book_outlined, size: 22, color: tint),
              ),
            )
          : Icon(Icons.menu_book_outlined, size: 22, color: tint),
    );
  }
}
