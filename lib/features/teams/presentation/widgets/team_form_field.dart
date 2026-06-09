import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/textforms/main_text_form.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Inline-labelled cream input matching the design's `.field` block.
/// Renders label, control with optional trailing widget, optional counter,
/// and optional error / hint copy.
class TeamFormField extends StatelessWidget {
  const TeamFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.focusNode,
    this.trailing,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
    this.monospace = false,
    this.onChanged,
    this.enabled = true,
    this.labelStyle,
    this.fillColor,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController controller;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final FocusNode? focusNode;
  final Widget? trailing;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool monospace;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextStyle? labelStyle;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final borderColor = hasError
        ? colors.warning
        : colors.olive.withValues(alpha: 0.18);
    final resolvedFill = hasError
        ? colors.warningSurface
        : (fillColor ?? colors.canvas.withValues(alpha: 0.55));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          label.tr().toUpperCase(),
          style: (labelStyle ?? ZaadType.fieldLabel).copyWith(
            color: hasError ? colors.warning : colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: ZaadRadii.mdAll,
            color: resolvedFill,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: MainTextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  isEnabled: enabled,
                  maxLength: maxLength,
                  minLines: minLines ?? 1,
                  maxLines: maxLines,
                  inputFormatters: inputFormatters,
                  textCapitalization: textCapitalization,
                  onChanged: onChanged,
                  hintText: hint?.tr(),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  style: AppTextStyles.bodyMedium.copyWith(
                    letterSpacing: monospace ? 2.5 : null,
                    color: colors.textPrimary,
                  ),
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPlaceholder,
                    letterSpacing: monospace ? 2.5 : null,
                  ),
                  inputDecorationTheme: const InputDecorationThemeData(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing!],
              if (maxLength != null) ...[
                const SizedBox(width: 6),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, _) {
                    final len = value.text.characters.length;
                    return ResponsiveText(
                      '$len / $maxLength',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: hasError
                            ? colors.warning
                            : (len >= 3 ? colors.success : colors.oliveSoft),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: colors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: ResponsiveText(
                  errorText!.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: colors.warning,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          ResponsiveText(
            helperText!.tr(),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: colors.oliveSoft,
            ),
          ),
        ],
      ],
    );
  }
}
