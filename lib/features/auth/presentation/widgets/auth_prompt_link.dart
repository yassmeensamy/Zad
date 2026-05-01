import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Bottom-of-screen prompt: a soft-coloured prefix followed by a
/// bold accent-coloured link, all wrapped in an [InkWell].
class AuthPromptLink extends StatelessWidget {
  const AuthPromptLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text.rich(
          TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              height: 1.4,
              color: colors.dateSoft,
            ),
            children: [
              TextSpan(text: prompt.tr()),
              TextSpan(
                text: action.tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  color: colors.olive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
