import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

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

  /// Shown in place of the hint while the items are still being fetched.
  final String? loadingLabel;
  final bool loading;

  bool get _interactive => enabled && !loading && items.isNotEmpty;

  Future<void> _openPicker(BuildContext context) async {
    final colors = context.appColors;
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ZaadRadii.xl)),
      ),
      builder: (_) => _PickerSheet<T>(
        items: items,
        itemLabel: itemLabel,
        selected: value,
        title: sheetTitle,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
      ),
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
                      color: hasValue
                          ? colors.oliveDeep
                          : colors.textSecondary,
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
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final String? title;
  final String? searchHint;
  final String? emptyLabel;

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
      () => setState(() => _query = _searchController.text.trim().toLowerCase()),
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
                  color: colors.olive.withValues(alpha: 0.2),
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
                      color: colors.olive.withValues(alpha: 0.55),
                    ),
                    filled: true,
                    fillColor: colors.olive.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ZaadRadii.lg),
                      borderSide: BorderSide.none,
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
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: colors.olive.withValues(alpha: 0.08),
                        ),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item == widget.selected;
                          return ListTile(
                            title: ResponsiveText(
                              widget.itemLabel(item),
                              style: AppTextStyles.labelLarge.copyWith(
                                letterSpacing: 0,
                                color: colors.oliveDeep,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: colors.olive,
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
