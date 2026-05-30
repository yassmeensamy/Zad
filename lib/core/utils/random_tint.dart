import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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

/// Deterministic tint — same [seed] always maps to the same colour.
/// Use a category/level id so an item renders identically across screens.
Color tintFor(int seed) => _palette[seed.abs() % _palette.length];
