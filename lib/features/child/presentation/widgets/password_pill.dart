import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Small inline pill placed inside the kid row that shows whether a
/// password has been set, and opens the password sheet when tapped.
class PasswordPill extends StatelessWidget {
  const PasswordPill({
    super.key,
    required this.hasPassword,
    required this.onTap,
  });

  final bool hasPassword;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = hasPassword ? colors.olive : colors.oliveSoft;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZaadRadii.sm),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 10, 7),
          decoration: BoxDecoration(
            color: hasPassword
                ? colors.olive.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(ZaadRadii.sm),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                hasPassword ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 14,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ResponsiveText(
                  hasPassword
                      ? 'create_profiles.password_set'
                      : 'create_profiles.password_set_cta',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 11.5 * 0.18,
                    color: accent,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
