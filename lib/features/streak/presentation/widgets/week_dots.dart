import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class WeekDots extends StatelessWidget {
  const WeekDots({
    super.key,
    required this.progress,
    required this.todayIndex,
  });

  final List<bool> progress;
  final int todayIndex;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _labels.length; i++)
          _DayDot(
            label: _labels[i],
            done: progress.length > i ? progress[i] : false,
            isToday: i == todayIndex,
          ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final Decoration decoration;

    if (done) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.heroGlow, colors.heroAmberDeep],
        ),
        border: Border.all(color: colors.heroGlow.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: colors.heroAmber.withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.heroInk.withValues(alpha: 0.10),
        border: Border.all(color: colors.heroGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.heroGlow.withValues(alpha: 0.14),
            blurRadius: 0,
            spreadRadius: 4,
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.heroInk.withValues(alpha: 0.06),
        border: Border.all(color: colors.heroInk.withValues(alpha: 0.14)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3.5),
          decoration: decoration,
          alignment: Alignment.center,
          child: Icon(
            Icons.check_rounded,
            size: 11,
            color: done ? colors.heroInk : Colors.transparent,
          ),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          label,
          style: AppTextStyles.eyebrow(
            fontSize: 8,
            tracking: 0.22,
            color: isToday
                ? colors.heroGold
                : colors.heroInk.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
