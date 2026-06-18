import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Shared header for the form dialogs (change-password, delete-account, …):
/// a centered eyebrow, a "lead + italic accent" title, and a short accent rule.
///
/// All three slots are translation keys. Set [danger] to recolor the eyebrow,
/// accent and rule with the theme error color for destructive dialogs.
class ZaadDialogHeader extends StatelessWidget {
  const ZaadDialogHeader({
    super.key,
    required this.eyebrowKey,
    required this.titleLeadKey,
    required this.titleAccentKey,
    this.danger = false,
  });

  final String eyebrowKey;
  final String titleLeadKey;
  final String titleAccentKey;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final eyebrowColor =
        danger ? errorColor.withValues(alpha: 0.85) : colors.oliveSoft;
    final accentColor = danger ? errorColor : colors.textArabic;
    final ruleColor = danger ? errorColor : colors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ResponsiveText(
            eyebrowKey,
            textAlign: TextAlign.center,
            style: ZaadType.eyebrowSm.copyWith(color: eyebrowColor),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: ZaadType.titleAccent.copyWith(color: colors.oliveDeep),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${titleLeadKey.tr()} '),
                  TextSpan(
                    text: titleAccentKey.tr(),
                    style: AppTextStyles.titleLarge.copyWith(
                      fontStyle: FontStyle.italic,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 28, height: 1, color: ruleColor),
        ],
      ),
    );
  }
}
