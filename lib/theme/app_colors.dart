import 'package:flutter/material.dart';

/// Raw Desert Sand palette. Internal to the theme layer.
/// Outside `theme/`, use `context.colorScheme.X` or `context.appColors.Y`.
class AppColors {
  AppColors._();

  // Desert Sand — warm paper canvas
  static const Color ivory = Color(0xFFF4ECD8);
  static const Color sand = Color(0xFFE9D9B8);
  static const Color dune = Color(0xFFDBC59A);

  // Lighter desert variants — used by the splash/login backdrop.
  static const Color ivoryLight = Color(0xFFF6EEDB);
  static const Color sandLight = Color(0xFFECDCBC);
  static const Color duneLight = Color(0xFFDFC79A);

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

  // Cream paper surfaces — page backdrop & ornamental cream cards.
  static const Color creamLight = Color(0xFFFBF6E8);
  static const Color creamSand = Color(0xFFF2E7CC);
  static const Color creamMid = Color(0xFFFAF1D8);
  static const Color creamDeep = Color(0xFFF1E3C2);

  // Decorative flame palette — used by the streak flame painter.
  static const Color amberGlow = Color(0xFFE0A560);
  static const Color flameHalo = Color(0xFFF0B862);
  static const Color flameLight = Color(0xFFFCE5BC);
  static const Color flameGold = Color(0xFFF1C57A);
  static const Color flameCore = Color(0xFFFFF6D9);

  // Hero card — deep brown-black shadow + abyss olive gradient stop.
  static const Color shadowDeep = Color(0xFF14100C);
  static const Color oliveAbyss = Color(0xFF161D0F);

  // Bottom-sheet gradient bottom — a warm sand softer than `canvasRaised`.
  static const Color paperSand = Color(0xFFEEE0BD);

  // Peach-rose tint used to back warning icons & error-state input fills.
  static const Color roseBlush = Color(0xFFF5E0DC);

  // Status — tinted slightly toward the warm palette
  static const Color success = Color(0xFF6B8E3D);
  static const Color warning = Color(0xFFD4933A);
  static const Color error = Color(0xFFB44A2C);
  static const Color info = Color(0xFF4A6B8A);

  // Illuminated-manuscript palette — gilded surfaces & inks for the
  // Decree and Join-Team screens. `goldLight` reuses [flameLight].
  static const Color goldMid = Color(0xFFE8B968);
  static const Color goldDeep = Color(0xFFA67027);
  static const Color goldDark = Color(0xFF8E5C1F);
  static const Color manuscriptInk = Color(0xFF2A1B0A);

  // Brighter parchment gradient used by the Decree (create-success)
  // celebration screen — distinct from the standard cream-paper canvas.
  static const Color parchmentTop = Color(0xFFFDF7E6);
  static const Color parchmentBottom = Color(0xFFF3E5C0);

  // Brown inks used on the parchment for the medallion monogram and the
  // close-button glyph on the Decree screen.
  static const Color inkBrown = Color(0xFF3E2614);
  static const Color inkBrownDeep = Color(0xFF5E3820);

  // Green confirmation seal on the Decree medallion.
  static const Color sealGreen = Color(0xFF7AAE6F);
  static const Color sealGreenDeep = Color(0xFF4F7A47);

  // Closed-keyhole error tones paired with the manuscript golds.
  static const Color errRimLight = Color(0xFFD27866);
  static const Color errRimDark = Color(0xFF8B3A30);
  static const Color errStroke = Color(0xFFB5564A);
}
