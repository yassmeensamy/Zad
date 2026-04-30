import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/profile_section.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({super.key, required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasTrailingWidget = item.trailing != null;
    final hasTrailingText = item.trailingText != null;

    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      child: InkWell(
        onTap: item.onTap,
        splashColor: Colors.white.withValues(alpha: 0.85),
        highlightColor: Colors.white.withValues(alpha: 0.85),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: hasTrailingWidget ? 4 : 10,
          ),
          child: Row(
            children: [
              _buildIconContainer(colors),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText(
                  item.titleKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textArabic,
                    height: 1.2,
                  ),
                ),
              ),
              if (hasTrailingText) ...[
                ResponsiveText(
                  item.trailingText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.olive.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (hasTrailingWidget)
                item.trailing!
              else
                Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: colors.olive.withValues(alpha: 0.45),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildIconContainer(AppColorsTheme colors) {
    return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.oliveLeaf.withValues(alpha: 0.22),
                    colors.olive.withValues(alpha: 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.olive.withValues(alpha: 0.20),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 16, color: colors.oliveDeep),
            );
  }
}
