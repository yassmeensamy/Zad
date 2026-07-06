import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class AuthAppleButton extends StatelessWidget {
  const AuthAppleButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomButton.full(
      onTap: onTap,
      loading: loading,
      theme: CustomButtonTheme(
        height: 46,
        borderRadius: 14,
        // Same opaque surface + olive ink as the Google button so the two
        // social buttons read as a consistent pair in light and dark.
        backgroundColor: colors.inputSurface,
        borderColor: colors.oliveSoft.withValues(alpha: 0.22),
        textColor: colors.oliveDeep,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apple, size: 20, color: colors.oliveDeep),
          const SizedBox(width: 10),
          ResponsiveText(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}
