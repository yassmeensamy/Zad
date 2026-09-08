import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Opens the searchable bottom-sheet picker used by [AppDropdownField], for
/// callers that need a different trigger (a filter pill, a menu entry, …).
/// Resolves to the picked item, or null when the sheet is dismissed.
Future<T?> showAppPickerSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T item) itemLabel,
  T? selected,
  String? title,
  String? searchHint,
  String? emptyLabel,
  String Function(T item)? itemSubtitle,
  Widget Function(T item)? itemLeading,
  bool searchable = true,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // The raised sheet token, not `canvas` — in dark the page base is a near
    // black (#140F0A) that swallowed the whole picker; `sheetSurface` lifts it
    // to the same brown the team sheets and dialogs sit on. The hairline keeps
    // the lifted edge legible against the scrim.
    backgroundColor: colors.sheetSurface,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(ZaadRadii.xl),
      ),
      side: BorderSide(color: colors.borderSubtle),
    ),
    builder: (_) => _PickerSheet<T>(
      items: items,
      itemLabel: itemLabel,
      selected: selected,
      title: title,
      searchHint: searchHint,
      emptyLabel: emptyLabel,
      itemSubtitle: itemSubtitle,
      itemLeading: itemLeading,
      searchable: searchable,
    ),
  );
}

/// A tappable form field that opens a searchable bottom-sheet picker, styled to
/// match the onboarding text/date fields (canvas fill, olive border, leading
/// icon, trailing chevron). Generic over the item type [T].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hintText,
    this.sheetTitle,
    this.searchHint,
    this.emptyLabel,
    this.prefixIcon,
    this.enabled = true,
    this.loadingLabel,
    this.loading = false,
    this.itemSubtitle,
    this.itemLeading,
    this.searchable = true,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onChanged;
  final T? value;
  final String? hintText;
  final String? sheetTitle;
  final String? searchHint;
  final String? emptyLabel;
  final IconData? prefixIcon;
  final bool enabled;

  /// Forwarded to the picker sheet — see [showAppPickerSheet].
  final String Function(T item)? itemSubtitle;
  final Widget Function(T item)? itemLeading;
  final bool searchable;

  /// Shown in place of the hint while the items are still being fetched.
  final String? loadingLabel;
  final bool loading;

  bool get _interactive => enabled && !loading && items.isNotEmpty;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showAppPickerSheet<T>(
      context: context,
      items: items,
      itemLabel: itemLabel,
      selected: value,
      title: sheetTitle,
      searchHint: searchHint,
      emptyLabel: emptyLabel,
      itemSubtitle: itemSubtitle,
      itemLeading: itemLeading,
      searchable: searchable,
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value != null;
    final label = loading
        ? (loadingLabel ?? hintText ?? '')
        : hasValue
        ? itemLabel(value as T)
        : (hintText ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        onTap: _interactive ? () => _openPicker(context) : null,
        child: Opacity(
          opacity: _interactive ? 1 : 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: colors.canvas,
              borderRadius: BorderRadius.circular(ZaadRadii.lg),
              border: Border.all(
                color: colors.olive.withValues(alpha: 0.20),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 18, color: colors.oliveDeep),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ResponsiveText(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      letterSpacing: 0,
                      color: hasValue ? colors.oliveDeep : colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.olive.withValues(alpha: 0.55),
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: colors.olive.withValues(alpha: 0.55),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.items,
    required this.itemLabel,
    required this.selected,
    this.title,
    this.searchHint,
    this.emptyLabel,
    this.itemSubtitle,
    this.itemLeading,
    this.searchable = true,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final String? title;
  final String? searchHint;
  final String? emptyLabel;

  /// Optional second line under [itemLabel] — e.g. a language's English name
  /// beside its native one.
  final String Function(T item)? itemSubtitle;

  /// Optional leading widget per row, for pickers that carry a badge or flag.
  final Widget Function(T item)? itemLeading;

  /// Whether to show the search field. Off for short, fixed lists where the
  /// box is noise and only serves to raise the keyboard over the options.
  final bool searchable;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    if (_query.isEmpty) return widget.items;
    return widget.items
        .where((i) => widget.itemLabel(i).toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final filtered = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (widget.title != null) ...[
                const SizedBox(height: 14),
                ResponsiveText(
                  widget.title!,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.oliveDeep,
                  ),
                ),
              ],
              if (!widget.searchable)
                const SizedBox(height: 12)
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.labelLarge.copyWith(
                      letterSpacing: 0,
                      color: colors.oliveDeep,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.searchHint,
                      hintStyle: AppTextStyles.labelLarge.copyWith(
                        letterSpacing: 0,
                        color: colors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      // A 4% olive tint was invisible on the dark sheet; the
                      // frosted card film reads as a raised field in both themes,
                      // and the hairline gives it an edge to sit on.
                      filled: true,
                      fillColor: colors.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ZaadRadii.lg),
                        borderSide: BorderSide(color: colors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ZaadRadii.lg),
                        borderSide: BorderSide(color: colors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ZaadRadii.lg),
                        borderSide: BorderSide(
                          color: colors.accent.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: ResponsiveText(
                          widget.emptyLabel ?? '',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: colors.borderSubtle),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item == widget.selected;
                          final subtitle = widget.itemSubtitle?.call(item);
                          return ListTile(
                            // The selection cue is the accent (amber in both
                            // themes) — plain olive turned muted green on the
                            // dark sheet and barely registered as "picked".
                            selected: isSelected,
                            selectedTileColor: colors.accent.withValues(
                              alpha: 0.10,
                            ),
                            leading: widget.itemLeading?.call(item),
                            title: ResponsiveText(
                              widget.itemLabel(item),
                              style: AppTextStyles.labelLarge.copyWith(
                                letterSpacing: 0,
                                color: isSelected
                                    ? colors.accent
                                    : colors.oliveDeep,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            // Plain [Text]: subtitles carry caller-supplied
                            // content (a language's English name), not a
                            // translation key, so it must not go through `.tr()`.
                            subtitle: subtitle == null
                                ? null
                                : Text(
                                    subtitle,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11,
                                      letterSpacing: 0.4,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: colors.accent,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
