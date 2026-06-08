import 'package:flutter/material.dart';

import 'date_ember_palette.dart';

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

  // ── Date & Ember night canvas (dark mode) ─────────────────────────────
  // The roasted-brown ramp lifted straight from the "Date & Ember" design:
  // base (#0E0905) → surface (#1A120B) → raised (#271A10), with #140F0A as the
  // page canvas. Lightness steps GROW as the ramp rises so cards and containers
  // separate clearly from the page. `canvasNight` is the page surface;
  // `nightLow` recesses below it and the ramp above lifts cards, sheets, menus
  // & the brightest containers. The backdrop vignette runs raised→surface→base.
  static const Color canvasNight = DateEmber.canvas; // canvas — page bg
  static const Color canvasNight2 = DateEmber.raised; // raised — backdrop top
  static const Color nightSurface = DateEmber.surface; // surface — backdrop mid
  static const Color nightLow = DateEmber.base; // base — recessed / bottom
  static const Color nightRaised = DateEmber.raised; // raised surface (cards)
  static const Color nightHigh = DateEmber.raised; // highest surface
  static const Color nightTop = DateEmber.raised; // brightest container
  static const Color nightOutline = DateEmber.glassBorder; // amber hairline
  static const Color nightOutlineVariant = DateEmber.hairline; // ivory hairline

  // Container & frosted-surface tints, all sourced from the Date & Ember
  // palette so the whole dark mode derives from one set of colours.
  static const Color nightBeige = DateEmber.raised; // warm container
  static const Color nightGlass = Color(0x1FF4ECD8); // ~12% ivory frosted film

  // Brightened accents tuned for legibility on the dark canvas — sourced from
  // the Date & Ember palette.
  static const Color amberLight = DateEmber.amberLight; // highlight gold
  static const Color oliveLight = DateEmber.olive; // success olive

  // Ember — the warm CTA accent for dark mode (terracotta orange).
  // Matches the Date & Ember CTA: ember-light (#E07A48) → ember (#C9512B).
  static const Color ember = DateEmber.ember; // CTA base
  static const Color emberBright = DateEmber.emberLight; // CTA gradient top
  static const Color emberDeep = DateEmber.emberDeep; // CTA gradient bottom
  static const Color emberInk = DateEmber.emberInk; // ink over ember fills

  // ── Date & Ember metallic disc ramps (avatars / podium) ───────────────
  // Sourced from the Date & Ember palette so the leaderboard discs, podium
  // pedestals and any avatar gradients all read from AppColors. `disc`-prefixed
  // to stay distinct from the manuscript golds above.
  static const Color discGoldHi = DateEmber.goldHi;
  static const Color discGoldMid = DateEmber.goldMid;
  static const Color discGoldLo = DateEmber.goldLo;
  static const Color discGoldInk = DateEmber.goldInk;
  static const Color discSilverHi = DateEmber.silverHi;
  static const Color discSilverMid = DateEmber.silverMid;
  static const Color discSilverLo = DateEmber.silverLo;
  static const Color discBronzeHi = DateEmber.bronzeHi;
  static const Color discBronzeMid = DateEmber.bronzeMid;
  static const Color discBronzeLo = DateEmber.bronzeLo;
  static const Color discBronzeInk = DateEmber.bronzeInk;
  static const Color discOliveHi = DateEmber.oliveHi;
  static const Color discOliveMid = DateEmber.oliveMid;
  static const Color discOliveLo = DateEmber.oliveLo;
  static const Color discOliveInk = DateEmber.oliveInk;
  static const Color discDateHi = DateEmber.dateHi;
  static const Color discDateMid = DateEmber.dateMid;
  static const Color discDateLo = DateEmber.dateLo;

  // Ivory ink at fixed alphas — text & hairlines over the night canvas.
  static const Color ivory78 = Color(0xC7F4ECD8); // secondary text
  static const Color ivory62 = DateEmber.txtMute; // Date & Ember muted text
  static const Color ivory60 = Color(0x99F4ECD8); // tertiary text
  static const Color ivory40 = Color(0x66F4ECD8); // placeholder text
  static const Color ivory32 = Color(0x52F4ECD8); // strong border
  static const Color ivory16 = Color(0x29F4ECD8); // default border
  static const Color ivory08 = Color(0x14F4ECD8); // subtle border / overlay
  static const Color ivory06 = Color(0x0FF4ECD8); // frosted card fill

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
  static const Color amberGlow = DateEmber.amber;
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
