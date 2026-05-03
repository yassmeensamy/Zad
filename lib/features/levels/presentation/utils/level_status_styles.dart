import 'package:flutter/material.dart';

import '../../../../theme/app_color_scheme.dart';
import '../../data/models/level_model.dart';

typedef LevelBadgeColors = ({Color bg, Color border, Color fg});
typedef LevelBadgeIcon = ({IconData icon, double size});
typedef LevelChipStyle = ({
  String labelKey,
  Color fg,
  Color bg,
  IconData icon,
});

extension LevelStatusStyles on LevelStatus {
  /// Round badge bg/border/fg.
  LevelBadgeColors badgeColors(AppColorsTheme c, Color tint) => switch (this) {
    LevelStatus.completed => (bg: tint, border: tint, fg: c.textInverse),
    LevelStatus.unlocked || LevelStatus.inProgress => (
      bg: c.canvas,
      border: tint,
      fg: tint,
    ),
    LevelStatus.locked || LevelStatus.unknown => (
      bg: c.canvasRaised,
      border: c.borderDefault,
      fg: c.textTertiary,
    ),
  };

  /// Icon to render inside the badge — `null` means render the order number.
  LevelBadgeIcon? get badgeIcon => switch (this) {
    LevelStatus.completed => (icon: Icons.check_rounded, size: 18),
    LevelStatus.locked || LevelStatus.unknown => (
      icon: Icons.lock_outline_rounded,
      size: 16,
    ),
    LevelStatus.unlocked || LevelStatus.inProgress => null,
  };

  /// Border colour for the row card.
  Color tileBorder(AppColorsTheme c, Color tint) => switch (this) {
    LevelStatus.completed => tint.withValues(alpha: 0.45),
    LevelStatus.unlocked || LevelStatus.inProgress =>
      tint.withValues(alpha: 0.30),
    LevelStatus.locked || LevelStatus.unknown => c.borderSubtle,
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
