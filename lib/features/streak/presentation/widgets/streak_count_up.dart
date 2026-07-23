import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class StreakCountUp extends StatefulWidget {
  const StreakCountUp({super.key, required this.target});

  final int target;

  @override
  State<StreakCountUp> createState() => _StreakCountUpState();
}

class _StreakCountUpState extends State<StreakCountUp> {
  LinearGradient? _gradient;
  Rect? _cachedRect;
  Shader? _cachedShader;

  Shader _shaderFor(Rect rect) {
    if (_cachedRect == rect && _cachedShader != null) return _cachedShader!;
    _cachedRect = rect;
    return _cachedShader = _gradient!.createShader(rect);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
      colors: [colors.heroGoldLight, colors.heroGold, colors.heroAmber],
    );
    if (gradient != _gradient) {
      _gradient = gradient;
      _cachedRect = null;
      _cachedShader = null;
    }

    final numberStyle = AppTextStyles.numericLarge.copyWith(
      fontStyle: FontStyle.italic,
      fontSize: 56,
      height: 0.85,
      letterSpacing: -1.8,
      color: AppColors.white,
      shadows: [
        Shadow(
          color: colors.heroAmber.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return RepaintBoundary(
      child: ShaderMask(
        shaderCallback: _shaderFor,
        child: TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: widget.target),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) =>
              ResponsiveText('$value', style: numberStyle),
        ),
      ),
    );
  }
}
