import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Visual variants for [ZaadPrimaryButton].
enum ZaadButtonVariant {
  /// Olive gradient — the default brand CTA.
  primary,

  /// Red gradient — for destructive confirmation.
  danger,
}

/// Canonical primary CTA used across screens, dialogs, and bottom sheets.
///
/// Replaces the auth/edit-profile/dialog/language-dialog hand-rolled gradient
/// buttons with one component so spacing, gradient stops, height, radius, and
/// loading-spinner all stay in lockstep.
class ZaadPrimaryButton extends StatelessWidget {
  const ZaadPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
    this.variant = ZaadButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 48,
    this.borderRadius = ZaadRadii.lg,
    this.fontSize = 14,
    this.letterSpacing,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool enabled;
  final ZaadButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double borderRadius;
  final double fontSize;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;

    final isDanger = variant == ZaadButtonVariant.danger;
    final gradientColors = isDanger
        ? <Color>[
            Color.alphaBlend(errorColor.withValues(alpha: 0.85), colors.canvas),
            errorColor,
            Color.alphaBlend(
              colors.oliveDeep.withValues(alpha: 0.35),
              errorColor,
            ),
          ]
        : <Color>[colors.oliveSoft, colors.olive, colors.oliveDeep];
    final shadowColor = isDanger
        ? errorColor.withValues(alpha: 0.32)
        : colors.oliveDeep.withValues(alpha: 0.28);

    final disabled = !enabled || loading;
    final foreground = colors.canvas;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: SizedBox(
              height: height,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(foreground),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leadingIcon != null) ...[
                            Icon(leadingIcon, size: 18, color: foreground),
                            const SizedBox(width: 10),
                          ],
                          ResponsiveText(
                            label,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: letterSpacing,
                              color: foreground,
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: 10),
                            Icon(trailingIcon, size: 18, color: foreground),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
