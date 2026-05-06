import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/level_model.dart';
import '../utils/level_status_styles.dart';

class LevelStatusChip extends StatelessWidget {
  const LevelStatusChip({super.key, required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final style = level.status.chipStyle(context.appColors, tint);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: style.fg),
          const SizedBox(width: 4),
          ResponsiveText(
            style.labelKey,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }
}
