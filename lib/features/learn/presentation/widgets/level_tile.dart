import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/learn_level.dart';

class LevelTile extends StatelessWidget {
  const LevelTile({
    super.key,
    required this.level,
    required this.tint,
    required this.isLast,
    this.onTap,
  });

  final LearnLevel level;
  final Color tint;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locked = level.isLocked;
    final completed = level.isCompleted;
    final unlocked = level.isUnlocked;

    final cardBg = locked
        ? colors.canvasRaised.withValues(alpha: 0.55)
        : colors.canvasRaised;
    final borderColor = completed
        ? tint.withValues(alpha: 0.45)
        : unlocked
            ? tint.withValues(alpha: 0.30)
            : colors.borderSubtle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Rail(
            tint: tint,
            level: level,
            isLast: isLast,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: locked ? null : onTap,
                  borderRadius: ZaadRadii.xlAll,
                  splashColor: tint.withValues(alpha: 0.08),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: ZaadRadii.xlAll,
                      border: Border.all(color: borderColor, width: 0.8),
                      boxShadow: locked
                          ? const []
                          : [
                              BoxShadow(
                                color: colors.oliveDeep
                                    .withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ResponsiveText(
                                  level.titleKey,
                                  maxLines: 1,
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
                              ),
                              const SizedBox(width: 8),
                              _StateChip(
                                level: level,
                                tint: tint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ResponsiveText(
                            level.descriptionKey,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMedium.copyWith(
                              letterSpacing: 0,
                              color: locked
                                  ? colors.textPlaceholder
                                  : colors.textSecondary,
                            ),
                          ),
                          if (unlocked) ...[
                            const SizedBox(height: 12),
                            _LineProgress(
                              progress: level.progress,
                              tint: tint,
                            ),
                            const SizedBox(height: 6),
                            ResponsiveText(
                              'learn.progress.percent'.tr(
                                args: ['${(level.progress * 100).round()}'],
                              ),
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                color: tint,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.tint,
    required this.level,
    required this.isLast,
  });

  final Color tint;
  final LearnLevel level;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final completed = level.isCompleted;
    final unlocked = level.isUnlocked;

    final badgeBg = completed
        ? tint
        : unlocked
            ? colors.canvas
            : colors.canvasRaised;
    final badgeBorder = completed
        ? tint
        : unlocked
            ? tint
            : colors.borderDefault;
    final badgeFg = completed
        ? colors.textInverse
        : unlocked
            ? tint
            : colors.textTertiary;

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeBg,
              border: Border.all(color: badgeBorder, width: 1.4),
              boxShadow: [
                if (completed || unlocked)
                  BoxShadow(
                    color: tint.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: completed
                ? Icon(Icons.check_rounded, size: 18, color: badgeFg)
                : level.isLocked
                    ? Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: badgeFg,
                      )
                    : Text(
                        '${level.index}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: badgeFg,
                        ),
                      ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  color: completed
                      ? tint.withValues(alpha: 0.55)
                      : colors.borderSubtle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.level, required this.tint});

  final LearnLevel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final (labelKey, fg, bg, icon) = switch (level.status) {
      LearnLevelStatus.completed => (
          'learn.state.completed',
          tint,
          tint.withValues(alpha: 0.12),
          Icons.check_circle_rounded,
        ),
      LearnLevelStatus.unlocked => (
          'learn.state.in_progress',
          tint,
          tint.withValues(alpha: 0.10),
          Icons.play_arrow_rounded,
        ),
      LearnLevelStatus.locked => (
          'learn.state.locked',
          colors.textTertiary,
          colors.borderSubtle.withValues(alpha: 0.50),
          Icons.lock_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          ResponsiveText(
            labelKey,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineProgress extends StatelessWidget {
  const _LineProgress({required this.progress, required this.tint});

  final double progress;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Stack(
        children: [
          Container(height: 5, color: tint.withValues(alpha: 0.12)),
          FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: tint,
                borderRadius:
                    const BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
