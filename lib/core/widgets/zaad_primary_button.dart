import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Visual variants for [ZaadPrimaryButton].
enum ZaadButtonVariant {
  /// Olive gradient — the default brand CTA.
  primary,

  /// Gold/amber gradient with gold ink — for secondary "create / sign up"
  /// prompts that sit alongside the primary CTA (e.g. the guest why-login card).
  accent,

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
    this.fontWeight = FontWeight.w600,
    this.letterSpacing,
    this.iconSize = 18,
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
  final FontWeight fontWeight;
  final double? letterSpacing;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;

    final List<Color> gradientColors;
    final Color shadowColor;
    final Color foreground;
    switch (variant) {
      case ZaadButtonVariant.danger:
        gradientColors = [
          Color.alphaBlend(errorColor.withValues(alpha: 0.85), colors.canvas),
          errorColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.28), errorColor),
        ];
        shadowColor = errorColor.withValues(alpha: 0.32);
        foreground = colors.onCta;
      case ZaadButtonVariant.accent:
        gradientColors = [colors.accentSoft, colors.accent, colors.accentDeep];
        shadowColor = colors.accent.withValues(alpha: 0.32);
        foreground = colors.goldInk;
      case ZaadButtonVariant.primary:
        gradientColors = [colors.ctaTop, colors.ctaMid, colors.ctaBottom];
        shadowColor = colors.ctaBottom.withValues(alpha: 0.36);
        foreground = colors.onCta;
    }

    final disabled = !enabled || loading;

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
                            Icon(leadingIcon, size: iconSize, color: foreground),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: ResponsiveText(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: fontSize,
                                fontWeight: fontWeight,
                                letterSpacing: letterSpacing,
                                color: foreground,
                              ),
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: 10),
                            Icon(trailingIcon, size: iconSize, color: foreground),
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
