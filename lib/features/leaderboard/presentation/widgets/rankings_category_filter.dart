import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../../theme/theme.dart';

/// Horizontal chip strip that filters the individual leaderboard by category.
/// The leading "All" chip clears the filter (`category_id` omitted).
///
/// Tapping a chip animates the strip so that chip is centered in the viewport,
/// bringing partly/fully off-screen chips into view on either end.
class RankingsCategoryFilter extends StatelessWidget {
  const RankingsCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;

  /// `null` means the "All" chip is active.
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _Chip(
            label: 'All',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final c in categories)
            _Chip(
              label: c.name,
              selected: selectedId == c.id,
              onTap: () => onSelected(c.id),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap();
          // Center this chip in the strip — `context` sits inside the
          // horizontal ListView, so ensureVisible scrolls to reveal it.
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? colors.oliveDeep
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: ZaadRadii.pillAll,
            border: Border.all(
              color: selected
                  ? colors.oliveDeep
                  : colors.oliveSoft.withValues(alpha: 0.25),
            ),
          ),
          child: ResponsiveText(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.creamLight : colors.oliveDeep,
            ),
          ),
        ),
      ),
    );
  }
}
