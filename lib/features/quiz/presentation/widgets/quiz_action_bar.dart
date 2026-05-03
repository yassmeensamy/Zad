import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

class QuizActionBar extends StatelessWidget {
  const QuizActionBar({
    super.key,
    required this.canAct,
    required this.isSaved,
    required this.isLastInRound,
    required this.hasMoreRounds,
    required this.onSave,
    required this.onReport,
    required this.onNext,
  });

  final bool canAct;
  final bool isSaved;
  final bool isLastInRound;
  final bool hasMoreRounds;
  final VoidCallback onSave;
  final VoidCallback onReport;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final nextLabelKey = (isLastInRound && !hasMoreRounds)
        ? 'quiz.actions.finish'
        : 'quiz.actions.next';

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(
          top: BorderSide(color: colors.borderSubtle, width: 0.6),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _IconAction(
              icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              tooltipKey: 'quiz.actions.save',
              isHighlighted: isSaved,
              onTap: canAct ? onSave : null,
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.flag_outlined,
              tooltipKey: 'quiz.actions.report',
              isHighlighted: false,
              onTap: canAct ? onReport : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NextButton(
                labelKey: nextLabelKey,
                enabled: canAct,
                onTap: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltipKey,
    required this.isHighlighted,
    required this.onTap,
  });

  final IconData icon;
  final String tooltipKey;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final disabled = onTap == null;
    final iconColor = disabled
        ? colors.textPlaceholder
        : isHighlighted
            ? colors.accent
            : colors.oliveDeep;
    final borderColor = disabled
        ? colors.borderSubtle
        : isHighlighted
            ? colors.accent.withValues(alpha: 0.55)
            : colors.olive.withValues(alpha: 0.20);

    return Tooltip(
      message: tooltipKey.tr(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.canvasRaised.withValues(alpha: 0.6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.labelKey,
    required this.enabled,
    required this.onTap,
  });

  final String labelKey;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: ZaadRadii.lgAll,
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              color: colors.olive,
              borderRadius: ZaadRadii.lgAll,
            ),
            child: Center(
              child: Text(
                labelKey.tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colors.canvas,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
