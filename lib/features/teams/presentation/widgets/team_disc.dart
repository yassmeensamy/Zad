import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Round amber-gradient avatar disc used throughout the Teams feature.
///
/// Falls back to the first letter of [seed] if [label] is empty. A small
/// inner highlight + drop shadow gives the parchment-warm "stamp" feel
/// shown across the design canvas.
class TeamDisc extends StatelessWidget {
  const TeamDisc({
    super.key,
    required this.seed,
    this.label,
    this.size = 42,
    this.fontSize,
    this.borderColor,
    this.borderWidth = 0,
    this.useSerif = true,
  });

  final String seed;
  final String? label;
  final double size;
  final double? fontSize;
  final Color? borderColor;
  final double borderWidth;
  final bool useSerif;

  static const _palettes = <List<Color>>[
    [AppColors.amberSoft, AppColors.amberDeep],
    [AppColors.oliveLeaf, AppColors.olive],
    [AppColors.dateSoft, AppColors.dateDeep],
    [AppColors.amber, AppColors.date],
    [AppColors.oliveSoft, AppColors.oliveDeep],
  ];

  List<Color> get _gradient {
    final key = seed.trim();
    if (key.isEmpty) return _palettes.first;
    final i = key.hashCode.abs() % _palettes.length;
    return _palettes[i];
  }

  String get _initial {
    if (label != null && label!.isNotEmpty) return label!;
    final trimmed = seed.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final gradient = _gradient;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.30),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      child: Center(
        child: ResponsiveText(
          _initial,
          style: TextStyle(
            fontSize: fontSize ?? size * 0.42,
            fontWeight: useSerif ? FontWeight.w400 : FontWeight.w700,
            color: colors.canvas,
            height: 1,
          ),
        ),
      ),
    );
  }
}
