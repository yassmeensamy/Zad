import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Circular avatar that prefers a remote image and falls back to a tinted
/// circle showing the first letter of [name]. Use when an `imageUrl` may or
/// may not be available — keeps the layout stable in both states.
///
/// The fallback gradient is picked deterministically from a small palette
/// based on [name] so different users render in different (but stable) hues.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 60,
    this.fontSize,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final double? fontSize;

  static const _fontRatio = 0.45;
  static const _fadeIn = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget fallback() => _Initial(
      name: name,
      size: size,
      fontSize: fontSize ?? size * _fontRatio,
      gradient: _gradientFor(name, colors),
      foreground: colors.canvas,
    );

    return Semantics(
      label: name.trim().isEmpty ? 'avatar' : '$name avatar',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: _fadeIn,
                  placeholder: (_, _) => fallback(),
                  errorWidget: (_, _, _) => fallback(),
                )
              : fallback(),
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({
    required this.name,
    required this.size,
    required this.fontSize,
    required this.gradient,
    required this.foreground,
  });

  final String name;
  final double size;
  final double fontSize;
  final List<Color> gradient;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Center(
        child: ResponsiveText(
          _initialOf(name),
          style: TextStyle(
            fontFamily: AppTextStyles.headlineMedium.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: foreground,
            height: 1,
          ),
        ),
      ),
    );
  }
}

String _initialOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.characters.first.toUpperCase();
}

/// Picks a stable gradient for [name] from the desert/olive palette.
List<Color> _gradientFor(String name, AppColorsTheme colors) {
  final palette = <List<Color>>[
    [colors.olive, colors.oliveLeaf],
    [AppColors.amber, AppColors.amberDeep],
    [AppColors.date, AppColors.dateDeep],
    [colors.oliveLeaf, colors.olive],
  ];
  final key = name.trim();
  if (key.isEmpty) return palette.first;
  // Positive, stable index across runs.
  final index = key.hashCode.abs() % palette.length;
  return palette[index];
}
