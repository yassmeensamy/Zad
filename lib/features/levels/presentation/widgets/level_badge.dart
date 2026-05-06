import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/level_model.dart';
import '../utils/level_status_styles.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, required this.tint});

  final LevelModel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final palette = level.status.badgeColors(context.appColors, tint);
    final icon = level.status.badgeIcon;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.bg,
        border: Border.all(color: palette.border, width: 1.4),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon.icon, size: icon.size, color: palette.fg)
          : ResponsiveText(
              '${level.order}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: palette.fg,
              ),
            ),
    );
  }
}
