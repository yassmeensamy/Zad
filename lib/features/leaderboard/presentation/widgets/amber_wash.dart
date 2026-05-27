import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

class AmberWash extends StatelessWidget {
  const AmberWash({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.85),
            radius: 0.9,
            colors: [
              AppColors.amberGlow.withValues(alpha: 0.32),
              Colors.transparent,
            ],
          ),
        ),
        child: const SizedBox.expand(),
      );
}
