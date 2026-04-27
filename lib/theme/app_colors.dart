import 'package:flutter/material.dart';

/// Raw Desert Sand palette. Internal to the theme layer.
/// Outside `theme/`, use `context.colorScheme.X` or `context.appColors.Y`.
class AppColors {
  AppColors._();

  // Desert Sand — warm paper canvas
  static const Color ivory = Color(0xFFF4ECD8);
  static const Color sand = Color(0xFFE9D9B8);
  static const Color dune = Color(0xFFDBC59A);

  // Accents & ink
  static const Color amber = Color(0xFFC78B3E);
  static const Color amberDeep = Color(0xFFA76E22);
  static const Color amberSoft = Color(0xFFE8C088);
  static const Color date = Color(0xFF7A4A29);
  static const Color dateDeep = Color(0xFF4D2D17);
  static const Color dateSoft = Color(0xFF8D5C36);
  static const Color darkOlive = Color(0xFF3D3A1F);
  static const Color dustyOlive = Color(0xFF6B6644);

  // Olive — primary brand accent for the v2 designs
  static const Color olive = Color(0xFF3E4A2A);
  static const Color oliveDeep = Color(0xFF2A331C);
  static const Color oliveSoft = Color(0xFF56653B);
  static const Color oliveLeaf = Color(0xFF6B7A4D);

  // Dark-mode warm neutrals (kept in the same family)
  static const Color inkwell = Color(0xFF1F140A);
  static const Color sepia = Color(0xFF2E2014);
  static const Color cocoa = Color(0xFF3F2C1C);
  static const Color tobacco = Color(0xFF5A4128);

  // Pure neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);

  // Cream border tones — used for ornamental gradient borders.
  static const Color creamBorderLight = Color(0xFFF0E1BD);
  static const Color creamBorderDark = Color(0xFFA88C68);

  // Status — tinted slightly toward the warm palette
  static const Color success = Color(0xFF6B8E3D);
  static const Color warning = Color(0xFFD4933A);
  static const Color error = Color(0xFFB44A2C);
  static const Color info = Color(0xFF4A6B8A);
}
