import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The app-wide **Date & Ember** background for dark mode.
///
/// A roasted-brown radial vignette (raised → surface → base) with a tiled
/// Islamic-pattern wallpaper and a warm amber wash glowing from the top edge.
///
/// It is injected once behind the whole app via `MaterialApp.builder`, so every
/// dark screen shares it. Scaffolds are transparent in dark mode (see
/// `AppTheme`), letting this show through. It is purely decorative — every layer
/// ignores pointers.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        // radial-gradient(130% 75% at 50% -8%, #271A10, #1A120B 42%, #0E0905)
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.05),
            radius: 1.4,
            colors: [AppColors.nightRaised, AppColors.nightSurface, AppColors.nightLow],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Tiled Islamic-pattern wallpaper, screened over the canvas.
            Opacity(
              opacity: 0.05,
              child: Image(
                image: AssetImage('assets/images/islamic-pattern.png'),
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topLeft,
                color: AppColors.ivory,
                colorBlendMode: BlendMode.screen,
              ),
            ),
            // Warm amber wash near the top.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.95),
                  radius: 0.9,
                  colors: [
                    AppColors.washAmber.withValues(alpha: 0.16),
                    AppColors.washAmber.withValues(alpha: 0),
                  ],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
