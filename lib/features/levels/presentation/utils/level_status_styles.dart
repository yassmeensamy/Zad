import 'package:flutter/material.dart';

import '../../../../theme/app_color_scheme.dart';
import '../../data/models/level_model.dart';

typedef LevelBadgeColors = ({Color bg, Color border, Color fg});
typedef LevelBadgeIcon = ({IconData icon, double size});
typedef LevelChipStyle = ({String labelKey, Color fg, Color bg, IconData icon});

/// The raised surface under a darkening film — what a locked row is painted
/// with, badge and card alike.
///
/// [AppColorsTheme.overlayDark] is the one scrim token that shades in the right
/// direction in both brightnesses (a warm brown film over the sand, black over
/// the night surface), so the same expression works light and dark.
Color _shaded(AppColorsTheme c) =>
    Color.alphaBlend(c.overlayDark, c.canvasRaised);

extension LevelStatusStyles on LevelStatus {
  /// Round badge bg/border/fg.
  LevelBadgeColors badgeColors(AppColorsTheme c, Color tint) => switch (this) {
    LevelStatus.completed => (bg: tint, border: tint, fg: c.textInverse),
    LevelStatus.unlocked ||
    LevelStatus.inProgress => (bg: c.canvas, border: tint, fg: tint),
    LevelStatus.locked || LevelStatus.unknown => (
      bg: _shaded(c),
      border: c.borderDefault,
      fg: c.textTertiary,
    ),
  };

  /// Icon to render inside the badge — `null` means render the order number.
  LevelBadgeIcon? get badgeIcon => switch (this) {
    LevelStatus.completed => (icon: Icons.check_rounded, size: 18),
    LevelStatus.locked ||
    LevelStatus.unknown => (icon: Icons.lock_outline_rounded, size: 16),
    LevelStatus.unlocked || LevelStatus.inProgress => null,
  };

  /// Fill colour for the row card.
  ///
  /// Locked rows sit under a scrim instead of being faded out: thinning the
  /// raised surface left them *lighter* than the playable ones in light mode,
  /// which reads as washed out rather than shut.
  Color tileSurface(AppColorsTheme c) => switch (this) {
    LevelStatus.completed ||
    LevelStatus.unlocked ||
    LevelStatus.inProgress => c.canvasRaised,
    LevelStatus.locked || LevelStatus.unknown => _shaded(c),
  };

  /// Border colour for the row card.
  Color tileBorder(AppColorsTheme c, Color tint) => switch (this) {
    LevelStatus.completed => tint.withValues(alpha: 0.45),
    LevelStatus.unlocked ||
    LevelStatus.inProgress => tint.withValues(alpha: 0.30),
    // One step up from `borderSubtle`, which now sits lighter than the shaded
    // fill it is meant to outline.
    LevelStatus.locked || LevelStatus.unknown => c.borderDefault,
  };

  /// Right-side status chip — label, fg/bg, and icon.
  LevelChipStyle chipStyle(AppColorsTheme c, Color tint) => switch (this) {
    LevelStatus.completed => (
      labelKey: 'levels.state.completed',
      fg: tint,
      bg: tint.withValues(alpha: 0.12),
      icon: Icons.check_circle_rounded,
    ),
    LevelStatus.inProgress => (
      labelKey: 'levels.state.in_progress',
      fg: tint,
      bg: tint.withValues(alpha: 0.10),
      icon: Icons.play_arrow_rounded,
    ),
    LevelStatus.unlocked => (
      labelKey: 'levels.state.unlocked',
      fg: tint,
      bg: tint.withValues(alpha: 0.08),
      icon: Icons.lock_open_rounded,
    ),
    LevelStatus.locked || LevelStatus.unknown => (
      labelKey: 'levels.state.locked',
      fg: c.textTertiary,
      bg: c.borderSubtle.withValues(alpha: 0.50),
      icon: Icons.lock_outline_rounded,
    ),
  };
}
