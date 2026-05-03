import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

const _palette = <Color>[
  AppColors.amber,
  AppColors.amberDeep,
  AppColors.date,
  AppColors.dateDeep,
  AppColors.olive,
  AppColors.oliveDeep,
  AppColors.oliveLeaf,
  AppColors.dustyOlive,
];

final _random = Random();

Color randomTint() => _palette[_random.nextInt(_palette.length)];

List<Color> randomTints(int count) =>
    List<Color>.generate(count, (_) => randomTint());

/// Deterministic tint — same [seed] always maps to the same colour.
/// Use [CategoryModel.id] so a category renders identically across screens.
Color tintFor(int seed) => _palette[seed.abs() % _palette.length];
