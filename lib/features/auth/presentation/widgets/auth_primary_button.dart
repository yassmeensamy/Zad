import 'package:flutter/material.dart';

import '../../../../core/widgets/zaad_primary_button.dart';

/// Thin alias kept for the auth/onboarding screens. Delegates to the
/// canonical [ZaadPrimaryButton] so a single component drives every primary
/// CTA in the app.
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
    return ZaadPrimaryButton(
      label: label,
      onTap: onTap,
      loading: loading,
      enabled: enabled,
      height: 46,
    );
  }
}
