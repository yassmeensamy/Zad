import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'islamic_ornaments.dart';
import 'responsive_text.dart';

/// A quiet closing "tanbīh" — a humility note that disclaims responsibility for
/// any error and invites readers to send corrections.
///
/// Rendered as a centred, muted paragraph beneath a small star-rule ornament,
/// so it reads as a calm sign-off rather than a call to action. Reused at the
/// foot of the profile and home screens.
class TanbihNote extends StatelessWidget {
  const TanbihNote({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 30),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: padding,
      child: Column(
        children: [
          SizedBox(
            width: 130,
            child: StarRule(color: colors.accent, starSize: 9),
          ),
          const SizedBox(height: 16),
          ResponsiveText(
            'about.tanbih',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              height: 1.95,
              letterSpacing: 0.1,
              color: colors.textSecondary.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
