import 'package:flutter/material.dart';

/// Shared gradient recipes so avatar/icon "crest" discs render identically
/// across the app instead of copy-pasting the same [RadialGradient] geometry.
abstract final class BrandGradients {
  /// Top-left highlight origin shared by every crest/avatar disc.
  static const Alignment crestCenter = Alignment(-0.36, -0.44);

  /// Reach of the crest highlight.
  static const double crestRadius = 0.9;

  /// Crest fill running highlight → mid → edge. Pass three colors for the
  /// standard `0 / 0.55 / 1` ramp; any other count falls back to an even
  /// edge-to-edge blend (used by the two-tone stacked member avatars).
  static RadialGradient crest(List<Color> colors) => RadialGradient(
    center: crestCenter,
    radius: crestRadius,
    colors: colors,
    stops: colors.length == 3 ? const [0.0, 0.55, 1.0] : null,
  );
}
