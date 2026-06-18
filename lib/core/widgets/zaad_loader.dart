import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Canonical circular progress indicator for the app. Centralises the
/// `SizedBox + CircularProgressIndicator(strokeWidth: 2)` idiom that was
/// hand-rolled across feature widgets so size, stroke and the brand tint stay
/// consistent.
///
/// - [size] sizes the spinner (default 22 — the in-list / pagination size).
/// - [color] tints the arc; defaults to the brand olive.
/// - [value] drives a determinate arc (e.g. download progress); null is
///   indeterminate.
/// - Use [ZaadLoader.fill] for a centered, full-area page loader.
class ZaadLoader extends StatelessWidget {
  const ZaadLoader({
    super.key,
    this.size = 22,
    this.strokeWidth = 2,
    this.color,
    this.value,
  }) : _centered = false;

  /// Full-area centered loader for page/section bodies.
  const ZaadLoader.fill({
    super.key,
    this.size = 22,
    this.strokeWidth = 2,
    this.color,
    this.value,
  }) : _centered = true;

  final double size;
  final double strokeWidth;
  final Color? color;
  final double? value;
  final bool _centered;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: value,
        valueColor: AlwaysStoppedAnimation(color ?? context.appColors.olive),
      ),
    );
    return _centered ? Center(child: indicator) : indicator;
  }
}
