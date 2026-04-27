import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomButton.full(
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            label,
            style: Theme.of(context)
                .extension<CustomButtonTheme>()
                ?.textStyle
                ?.copyWith(color: colors.canvas),
          ),
          const SizedBox(width: 10),
          Icon(Icons.arrow_forward_rounded, size: 18, color: colors.canvas),
        ],
      ),
    );
  }
}
