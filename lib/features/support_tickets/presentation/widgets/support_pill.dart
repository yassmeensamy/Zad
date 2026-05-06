import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class SupportPill extends StatelessWidget {
  const SupportPill({
    super.key,
    required this.color,
    required this.label,
    this.icon,
    this.dot = false,
  });

  final Color color;
  final String label;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          ResponsiveText(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: dot ? 0.4 : 0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
