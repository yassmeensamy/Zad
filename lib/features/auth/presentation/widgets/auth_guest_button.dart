import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_loader.dart';
import '../../../../theme/theme.dart';

class AuthGuestButton extends StatelessWidget {
  const AuthGuestButton({
    super.key,
    required this.loading,
    required this.onTap,
  });

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: loading ? null : onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        foregroundColor: colors.olive,
        side: BorderSide(color: colors.oliveSoft.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
        ),
      ),
      child: loading
          ? const ZaadLoader(size: 18)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: colors.olive,
                ),
                const SizedBox(width: 10),
                ResponsiveText(
                  'auth.continue_guest',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.olive,
                  ),
                ),
              ],
            ),
    );
  }
}
