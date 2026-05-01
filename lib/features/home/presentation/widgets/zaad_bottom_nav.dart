import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class ZaadBottomNavItem {
  const ZaadBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class ZaadBottomNav extends StatelessWidget {
  const ZaadBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<ZaadBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(
          top: BorderSide(
            color: colors.olive.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavSlot(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ZaadBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final restColor = colors.textArabic.withValues(alpha: 0.50);
    final onOlive = colors.canvas;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors.oliveSoft, colors.olive, colors.oliveDeep],
                    )
                  : null,
              borderRadius: BorderRadius.circular(ZaadRadii.lg),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.oliveDeep.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      selected ? item.activeIcon : item.icon,
                      key: ValueKey<bool>(selected),
                      size: 22,
                      color: selected ? onOlive : restColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ResponsiveText(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: (selected
                              ? ZaadType.navLabelActive
                              : ZaadType.navLabel)
                          .copyWith(color: selected ? onOlive : restColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
