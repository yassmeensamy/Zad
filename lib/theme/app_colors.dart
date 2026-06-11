import 'package:flutter/material.dart';

/// Raw Desert Sand palette. Internal to the theme layer.
/// Outside `theme/`, use `context.colorScheme.X` or `context.appColors.Y`.
///
/// This is the single source of truth for both the warm Desert Sand light
/// theme and the roasted-brown **Date & Ember** dark theme (night canvas, gold
/// /amber accents, the ember CTA, ivory ink and the metallic disc ramps).
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
  static const Color canvasNight = Color(0xFF140F0A); // canvas — page bg
  static const Color canvasNight2 = Color(0xFF271A10); // raised — backdrop top
  static const Color nightSurface = Color(0xFF1A120B); // surface — backdrop mid
  static const Color nightLow = Color(0xFF0E0905); // base — recessed / bottom
  static const Color nightRaised = Color(0xFF271A10); // raised surface (cards)
  static const Color nightHigh = Color(0xFF271A10); // highest surface
  static const Color nightTop = Color(0xFF271A10); // brightest container
  static const Color nightOutline = Color(0x33E1A560); // amber hairline
  static const Color nightOutlineVariant = Color(0x14F4ECD8); // ivory hairline

  // Container & frosted-surface tints — the whole dark mode derives from one
  // set of roasted-brown colours.
  static const Color nightBeige = Color(0xFF271A10); // warm container
  static const Color nightGlass = Color(0x1FF4ECD8); // ~12% ivory frosted film

  // Gold / amber family — brightened accents tuned for legibility on the dark
  // canvas. `washAmber` is the bare amber wash behind glass borders.
  static const Color amberLight = Color(0xFFF1C57A); // highlight gold
  static const Color washAmber = Color(0xFFE1A560); // amber wash / glass tint
  static const Color oliveLight = Color(0xFF7A8A5A); // success olive

  // Ember — the warm CTA accent for dark mode (terracotta orange).
  // The Date & Ember CTA: ember-light (#E07A48) → ember (#C9512B).
  static const Color ember = Color(0xFFC9512B); // CTA base
  static const Color emberBright = Color(0xFFE07A48); // CTA gradient top
  static const Color emberDeep = Color(0xFFA53E1E); // CTA gradient bottom
  static const Color emberInk = Color(0xFF1A0E06); // ink over ember fills

  // ── Date & Ember metallic disc ramps (avatars / podium) ───────────────
  // The leaderboard discs, podium pedestals and any avatar gradients all read
  // from here. `disc`-prefixed to stay distinct from the manuscript golds.
  static const Color discGoldHi = Color(0xFFF1C57A);
  static const Color discGoldMid = Color(0xFFE0A560);
  static const Color discGoldLo = Color(0xFFA6622A);
  static const Color discGoldInk = Color(0xFF2A1B0A);
  static const Color discSilverHi = Color(0xFFF4EBDC);
  static const Color discSilverMid = Color(0xFFCDBFA6);
  static const Color discSilverLo = Color(0xFF8A7456);
  static const Color discBronzeHi = Color(0xFFE8A877);
  static const Color discBronzeMid = Color(0xFFC9512B);
  static const Color discBronzeLo = Color(0xFF7A2E15);
  static const Color discBronzeInk = Color(0xFF2A1206);
  static const Color discOliveHi = Color(0xFFA6B584);
  static const Color discOliveMid = Color(0xFF7A8A5A);
  static const Color discOliveLo = Color(0xFF42502E);
  static const Color discOliveInk = Color(0xFF1A2010);
  static const Color discDateHi = Color(0xFFD9A878);
  static const Color discDateMid = Color(0xFFA6622A);
  static const Color discDateLo = Color(0xFF5E3115);

  // App-update dialog medallion — the gilded disc highlight and the brown ink
  // for its arrow glyph. Kept constant across light/dark; the rest of the disc
  // ramp reuses [discGoldHi]/[discGoldMid]/[discGoldLo].
  static const Color medallionHighlight = Color(0xFFFCE9C6);
  static const Color medallionInk = Color(0xFF3A2510);

  // Ivory ink at fixed alphas — text & hairlines over the night canvas.
  static const Color ivory78 = Color(0xC7F4ECD8); // secondary text
  static const Color ivory62 = Color(0x9EF4ECD8); // Date & Ember muted text
  static const Color ivory60 = Color(0x99F4ECD8); // tertiary text
  static const Color ivory40 = Color(0x66F4ECD8); // placeholder text
  static const Color ivory32 = Color(0x52F4ECD8); // strong border
  static const Color ivory16 = Color(0x29F4ECD8); // default border
  static const Color ivory08 = Color(0x14F4ECD8); // subtle border / overlay
  static const Color ivory06 = Color(0x0FF4ECD8); // frosted card fill
  static const Color ivory02 = Color(0x05F4ECD8); // faintest glass film

  // Pure neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);

  // Cream border tones — used for ornamental gradient borders (light mode).
  static const Color creamBorderLight = Color(0xFFF0E1BD);
  static const Color creamBorderDark = Color(0xFFA88C68);

  // Ornamental dialog border — the dark-mode counterpart to the cream pair.
  // A gilded amber hairline fading to a faint ivory edge over the night canvas.
  static const Color dialogBorderDarkTop = Color(0x66E0A560); // amber @ 40%
  static const Color dialogBorderDarkBottom = Color(0x29F4ECD8); // ivory @ 16%

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

  // Support-ticket "close ticket" footer card. Surface: a soft translucent
  // sand paper in light (dark reuses [nightGlass]). Border: the olive brand at
  // a low alpha — olive reads green in light, ivory-olive in dark, so the two
  // border tones are pre-baked per theme to keep the widget brightness-agnostic.
  static const Color ticketCloseSurfaceLight = Color(0x8CE9D9B8); // sand @ 55%
  static const Color ticketCloseBorderLight = Color(0x293E4A2A); // olive @ 16%
  static const Color ticketCloseBorderDark = Color(0x3D7A8A5A); // oliveLight @ 24%

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

  // ── Centralised feature tones (previously inline hex literals) ────────────
  // Gilded gradient stops used by the team create / decree banners. Deeper than
  // the manuscript golds; pair with [olive] and the gold multiply blend.
  static const Color gildDeep = Color(0xFF6E5025); // banner gradient deep stop
  static const Color goldBlend = Color(0xFF8B6A2C); // logo multiply-blend gold

  // Date & Ember trend tints — the design's `--up` / `--down` (dark mode).
  static const Color trendUp = Color(0xFF9CCB8E); // gain / success arrow
  static const Color trendDown = Color(0xFFD98A6F); // loss / down arrow

  // Dark roasted-brown surfaces & scrims for dialogs (used at high alpha).
  // `cardNight*` are the force-update card gradient; `scrimNight` is the outer
  // backdrop vignette; `nightOliveCard` backs the team-home card in dark mode.
  static const Color cardNightTop = Color(0xFF281C12); // dialog card top
  static const Color cardNightBottom = Color(0xFF140E09); // dialog card bottom
  static const Color scrimNight = Color(0xFF080503); // backdrop outer scrim
  static const Color nightOliveCard = Color(0xFF10160B); // dark team-home card

  // Warm sand used by leaderboard surfaces at partial alpha.
  static const Color sandWarm = Color(0xFFDCCDB4);
}
