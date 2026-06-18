import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The brand "prefix + italic accent" hero title used across the auth and
/// onboarding screens (and a couple of dialogs): a centered [Text.rich] whose
/// leading run is the [ZaadType.titleHero] heading and whose trailing run is an
/// italic accent in [AppColorsTheme.textArabic].
///
/// Both runs are translation keys (resolved here, so callers pass keys, not
/// pre-translated strings). The defaults reproduce the most common treatment
/// (login / forgot-password); pass [baseStyle] / [accentStyle] / [suffix] to
/// match the screens that tweak the size or append punctuation.
class AccentRichTitle extends StatelessWidget {
  const AccentRichTitle({
    super.key,
    required this.prefixKey,
    required this.accentKey,
    this.baseStyle,
    this.accentStyle,
    this.suffix,
    this.textAlign = TextAlign.center,
  });

  /// Translation key for the leading (non-accented) run.
  final String prefixKey;

  /// Translation key for the italic accent run.
  final String accentKey;

  /// Heading style for the whole span. Defaults to
  /// `ZaadType.titleHero` tinted with [AppColorsTheme.oliveDeep].
  final TextStyle? baseStyle;

  /// Style for the accent run. Defaults to `AppTextStyles.bodyLarge`, italic,
  /// tinted with [AppColorsTheme.textArabic].
  final TextStyle? accentStyle;

  /// Optional literal appended after the accent (e.g. a trailing `?`).
  final String? suffix;

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base =
        baseStyle ?? ZaadType.titleHero.copyWith(color: colors.oliveDeep);
    final accent =
        accentStyle ??
        AppTextStyles.bodyLarge.copyWith(
          fontStyle: FontStyle.italic,
          color: colors.textArabic,
        );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: prefixKey.tr()),
          TextSpan(text: accentKey.tr(), style: accent),
          if (suffix != null) TextSpan(text: suffix),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
