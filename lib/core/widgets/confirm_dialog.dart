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
  });

  final IconData icon;
  final String titleKey;
  final String messageKey;
  final String confirmKey;
  final String cancelKey;

  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    required String titleKey,
    required String messageKey,
    required String confirmKey,
    String cancelKey = 'common.cancel',
  }) {
    return CustomDialog.show<bool>(
      context: context,
      child: ConfirmDialog(
        icon: icon,
        titleKey: titleKey,
        messageKey: messageKey,
        confirmKey: confirmKey,
        cancelKey: cancelKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
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
            color: errorColor.withValues(alpha: 0.10),
          ),
          child: Icon(icon, color: errorColor, size: 26),
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
            backgroundColor: errorColor,
            textColor: colors.canvas,
            borderRadius: 14,
          ),
          child: ResponsiveText(
            confirmKey,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: colors.canvas,
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
