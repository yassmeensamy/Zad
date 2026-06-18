import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'custom_button.dart';
import 'custom_dialog.dart';
import 'responsive_text.dart';

/// A destructive-action confirmation dialog (icon + title + subtitle +
/// confirm/cancel). Returns `true` when the user confirms, `null`/`false`
/// otherwise. Built on top of [CustomDialog] so it matches the app shell.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.messageKey,
    required this.confirmKey,
    this.cancelKey = 'common.cancel',
    this.confirmColor,
    this.confirmTextColor,
    this.iconColor,
    this.iconTint,
  });

  final IconData icon;
  final String titleKey;
  final String messageKey;
  final String confirmKey;
  final String cancelKey;

  /// Confirm CTA fill (and the default for [iconColor]). Defaults to the theme
  /// error color — the destructive treatment.
  final Color? confirmColor;

  /// Confirm CTA label color. Defaults to the canvas color.
  final Color? confirmTextColor;

  /// Icon glyph color. Defaults to [confirmColor] / error.
  final Color? iconColor;

  /// Base color of the round icon medallion (rendered at 10% alpha). Defaults
  /// to [iconColor].
  final Color? iconTint;

  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    required String titleKey,
    required String messageKey,
    required String confirmKey,
    String cancelKey = 'common.cancel',
    Color? confirmColor,
    Color? confirmTextColor,
    Color? iconColor,
    Color? iconTint,
  }) {
    return CustomDialog.show<bool>(
      context: context,
      child: ConfirmDialog(
        icon: icon,
        titleKey: titleKey,
        messageKey: messageKey,
        confirmKey: confirmKey,
        cancelKey: cancelKey,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
        iconColor: iconColor,
        iconTint: iconTint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final ctaColor = confirmColor ?? errorColor;
    final glyphColor = iconColor ?? ctaColor;
    final medallionTint = iconTint ?? glyphColor;
    final ctaTextColor = confirmTextColor ?? colors.canvas;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medallionTint.withValues(alpha: 0.10),
          ),
          child: Icon(icon, color: glyphColor, size: 26),
        ),
        const SizedBox(height: 14),
        ResponsiveText(
          titleKey,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          messageKey,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton.full(
          onTap: () => Navigator.of(context).pop(true),
          theme: CustomButtonTheme(
            height: 48,
            backgroundColor: ctaColor,
            textColor: ctaTextColor,
            borderRadius: 14,
          ),
          child: ResponsiveText(
            confirmKey,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: ctaTextColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: ResponsiveText(
            cancelKey,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
