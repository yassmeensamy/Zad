import 'package:flutter/material.dart';

/// Paints [backdrop] behind [child], but only in light mode.
///
/// In dark mode the global `AppBackdrop` (injected via `AppScaffold` in the
/// shell) already covers the screen, so [child] is returned unwrapped and no
/// extra layer is painted. This keeps screens free of `if (isDark) ...`
/// branches — they just declare their light backdrop and compose.
class LightModeBackdrop extends StatelessWidget {
  const LightModeBackdrop({
    super.key,
    required this.backdrop,
    required this.child,
  });

  /// The full-bleed layer painted behind [child] in light mode.
  final Widget backdrop;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return child;
    return Stack(
      children: [
        Positioned.fill(child: backdrop),
        child,
      ],
    );
  }
}
