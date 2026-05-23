import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Cream-paper screen background used throughout the Teams flow.
/// Mirrors the warm parchment gradient from the design canvas.
class TeamScaffold extends StatelessWidget {
  const TeamScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNav,
    this.extendBody = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.canvas,
      extendBody: extendBody,
      // When an app bar is supplied, let the cream gradient flow up
      // through the bar so the status-bar area, the bar, and the body
      // form a single continuous parchment surface (no seam).
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.backdropTop, colors.backdropBottom],
          ),
        ),
        child: SafeArea(bottom: false, child: child),
      ),
    );
  }
}
