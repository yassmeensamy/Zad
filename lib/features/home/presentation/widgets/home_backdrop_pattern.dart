import 'package:flutter/material.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../theme/theme.dart';

/// Light-mode page backdrop: a vertical cream wash with a faint tiled
/// Islamic pattern over it.
///
/// Dark mode is handled by the global `AppBackdrop` (injected in `main.dart`),
/// so this is only ever mounted under the light theme — see `HomeScreen`.
class HomeBackdropPattern extends StatelessWidget {
  const HomeBackdropPattern({super.key});

  /// Opacity of the tiled pattern over the cream wash.
  static const double _patternOpacity = 0.07;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.backdropTop, colors.backdropBottom],
          ),
        ),
        child: Opacity(
          opacity: _patternOpacity,
          child: Image.asset(
            AppImages.islamicPattern,
            repeat: ImageRepeat.repeat,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
