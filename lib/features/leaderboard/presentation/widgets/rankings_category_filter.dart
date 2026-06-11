import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';

/// Horizontally scrolling category chips (plus an "All" chip) that filter the
/// individual rankings.
class RankingsCategoryFilter extends StatelessWidget {
  const RankingsCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _CategoryChip(
            label: 'leaderboard.category_all'.tr(),
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final c in categories)
            _CategoryChip(
              label: c.name,
              selected: selectedId == c.id,
              onTap: () => onSelected(c.id),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.accent.withValues(alpha: 0.20),
                      colors.accentDeep.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            color: selected ? null : colors.cardSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? colors.accent.withValues(alpha: 0.45)
                  : colors.borderSubtle,
            ),
          ),
          child: ResponsiveText(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? colors.accent : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
