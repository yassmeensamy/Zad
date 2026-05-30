import 'dart:math';

import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,

    this.style,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.isSelectable = false,
    this.softWrap = true,
    this.textDecoration,
    this.args,
    this.namedArgs,
  });
  final String? text; // Allow text to be nullable
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isSelectable;
  final bool softWrap;
  final TextDecoration? textDecoration;
  final TextDirection? textDirection;

  /// Positional interpolation values forwarded to `.tr(args: ...)`. Use these
  /// instead of pre-translating with `key.tr(args: ...)` and passing the
  /// resolved string in (which double-translates).
  final List<String>? args;
  final Map<String, String>? namedArgs;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget
    }

    final effectiveStyle =
        style?.copyWith(decoration: textDecoration) ??
        TextStyle(decoration: textDecoration);

    if (isSelectable) {
      return SelectableText(
        text!.tr(args: args, namedArgs: namedArgs),
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        textScaler: ScaleSize.getTextScaler(context), // Use textScaler
      );
    }

    return Text(
      text!.tr(args: args, namedArgs: namedArgs),
      textDirection: textDirection,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textScaler: ScaleSize.getTextScaler(context), // Use textScaler
    );
  }
}

class ScaleSize {
  static double textScaleFactor(
    BuildContext context, {
    double maxTextScaleFactor = 2,
  }) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final systemScale = MediaQuery.textScaleFactorOf(context);

    final customScale = (deviceWidth / 1100) * maxTextScaleFactor;
    final finalScale = max(1, min(customScale, maxTextScaleFactor));

    return finalScale * systemScale;
  }

  static TextScaler getTextScaler(BuildContext context) =>
      TextScaler.linear(textScaleFactor(context));
}
