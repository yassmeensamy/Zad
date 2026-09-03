import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../onboarding_flow/data/country_model.dart';

/// One row of the country picker sheet. A null [country] is the "all countries"
/// entry, which clears the filter.
@immutable
class _CountryChoice {
  const _CountryChoice(this.country);

  final CountryModel? country;

  int? get id => country?.id;

  String get label => country?.displayName ?? 'leaderboard.country_all'.tr();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is _CountryChoice && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class RankingsCountryFilter extends StatelessWidget {
  const RankingsCountryFilter({
    super.key,
    required this.countries,
    required this.selectedId,
    required this.onSelected,
    this.loading = false,
  });

  final List<CountryModel> countries;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final bool loading;

  CountryModel? get _selected {
    for (final c in countries) {
      if (c.id == selectedId) return c;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final choice = await showAppPickerSheet<_CountryChoice>(
      context: context,
      items: [
        const _CountryChoice(null),
        for (final c in countries) _CountryChoice(c),
      ],
      itemLabel: (c) => c.label,
      selected: _CountryChoice(_selected),
      title: 'leaderboard.country_filter'.tr(),
      searchHint: 'leaderboard.country_search_hint'.tr(),
      emptyLabel: 'leaderboard.country_empty'.tr(),
    );
    if (choice != null) onSelected(choice.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = _selected;
    final active = selected != null;
    final flag = selected?.countryFlag;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading || countries.isEmpty ? null : () => _openPicker(context),
      child: Opacity(
        opacity: loading || countries.isEmpty ? 0.6 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(maxWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.accent.withValues(alpha: 0.20),
                      colors.accentDeep.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            color: active ? null : colors.cardSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? colors.accent.withValues(alpha: 0.45)
                  : colors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flag != null && flag.isNotEmpty)
                ResponsiveText(
                  flag,
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 13),
                )
              else
                Icon(
                  Icons.public_rounded,
                  size: 14,
                  color: active ? colors.accent : colors.textSecondary,
                ),
              const SizedBox(width: 6),
              Flexible(
                child: ResponsiveText(
                  selected?.name ?? 'leaderboard.country_all'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? colors.accent : colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              if (loading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: colors.textSecondary,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: active ? colors.accent : colors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
