import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'date_ember_palette.dart';

@immutable
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textPlaceholder;
  final Color textInverse;
  final Color textArabic;
  final Color dateSoft;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  final Color canvas;
  final Color canvasRaised;

  final Color accent;
  final Color accentSoft;
  final Color accentDeep;

  final Color olive;
  final Color oliveDeep;
  final Color oliveSoft;
  final Color oliveLeaf;

  // Primary CTA gradient (olive in light, ember in dark) + its on-color.
  final Color ctaTop;
  final Color ctaMid;
  final Color ctaBottom;
  final Color onCta;

  final Color success;
  final Color warning;
  final Color info;

  final Color overlayLight;
  final Color overlayDark;

  // Page backdrop gradient (home screen). Three stops give a premium vignette:
  // a softly lifted top, a base mid, and a deepened bottom for depth.
  final Color backdropTop;
  final Color backdropMid;
  final Color backdropBottom;

  // Desert Sand canvas — the shared splash / auth backdrop (DesertBackground).
  // A three-stop diagonal gradient (warm cream in light, the Date & Ember
  // roasted-brown vignette in dark), a soft central veil that lifts the form
  // area for input legibility, and the tint applied to the tiled
  // Islamic-pattern wallpaper. Resolved per brightness so the backdrop adapts
  // without the widget branching on Theme.of().
  final Color desertGradientTop;
  final Color desertGradientMid;
  final Color desertGradientBottom;
  final Color desertVeil;
  final Color desertPatternTint;

  // Cream-paper surfaces for amber CTA cards & the join-team dialog.
  final Color creamSurfaceTop;
  final Color creamSurfaceBottom;

  // Translucent surfaces for hadith-style cards & the dialog input field.
  final Color cardSurface;
  final Color inputSurface;

  // CustomDialog ornamental border gradient — two stops. Cream in light, a
  // gilded amber→ivory hairline in dark. (The dialog's inner surface reuses
  // [creamSurfaceTop]/[creamSurfaceBottom].)
  final Color dialogBorderTop;
  final Color dialogBorderBottom;

  // Bottom-sheet gradient bottom (paired with [canvas] for the top stop).
  final Color sheetSurface;

  // Streak hero banner (home screen) — a full-bleed gradient card. Olive in
  // light; the roasted-brown Date & Ember ramp in dark so it matches the
  // leaderboard surfaces instead of reading as a light-mode green.
  final Color heroSurfaceTop;
  final Color heroSurfaceMid;
  final Color heroSurfaceBottom;
  final Color heroShadow;

  // Streak-hero foreground accents. The hero is a dark surface in both
  // brightnesses (olive in light, roasted brown in dark), so these read the
  // same in either theme — they exist here only to keep the card's palette
  // defined centrally instead of hardcoded in the widget.
  final Color heroInk;
  final Color heroGlow;
  final Color heroGold;
  final Color heroGoldLight;
  final Color heroAmber;
  final Color heroAmberDeep;

  // Peach-rose tint that backs warning icons & error-state input fills.
  final Color warningSurface;

  // Support-ticket "close ticket" footer card — surface fill + hairline border.
  // Resolved per brightness here so the widget never branches on Theme.of().
  final Color ticketCloseSurface;
  final Color ticketCloseBorder;

  // Illuminated-manuscript palette — gilded surfaces & inks for the
  // Decree and Join-Team screens.
  final Color goldLight;
  final Color goldMid;
  final Color goldDeep;
  final Color goldDark;
  final Color goldInk;
  final Color manuscriptCream;
  final Color keyholeInk;

  // Brighter parchment gradient used by the Decree celebration screen.
  final Color parchmentTop;
  final Color parchmentBottom;

  // Brown inks used on the parchment Decree screen (medallion monogram,
  // body copy, close-button glyph).
  final Color inkBrown;
  final Color inkBrownDeep;

  // Green confirmation seal on the Decree medallion.
  final Color sealGreen;
  final Color sealGreenDeep;

  // Closed-keyhole error palette (paired with the manuscript golds).
  final Color errRimLight;
  final Color errRimDark;
  final Color errRose;
  final Color errStroke;

  const AppColorsTheme({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPlaceholder,
    required this.textInverse,
    required this.textArabic,
    required this.dateSoft,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.canvas,
    required this.canvasRaised,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.olive,
    required this.oliveDeep,
    required this.oliveSoft,
    required this.oliveLeaf,
    required this.ctaTop,
    required this.ctaMid,
    required this.ctaBottom,
    required this.onCta,
    required this.success,
    required this.warning,
    required this.info,
    required this.overlayLight,
    required this.overlayDark,
    required this.backdropTop,
    required this.backdropMid,
    required this.backdropBottom,
    required this.desertGradientTop,
    required this.desertGradientMid,
    required this.desertGradientBottom,
    required this.desertVeil,
    required this.desertPatternTint,
    required this.creamSurfaceTop,
    required this.creamSurfaceBottom,
    required this.cardSurface,
    required this.inputSurface,
    required this.dialogBorderTop,
    required this.dialogBorderBottom,
    required this.sheetSurface,
    required this.warningSurface,
    required this.ticketCloseSurface,
    required this.ticketCloseBorder,
    required this.heroSurfaceTop,
    required this.heroSurfaceMid,
    required this.heroSurfaceBottom,
    required this.heroShadow,
    required this.heroInk,
    required this.heroGlow,
    required this.heroGold,
    required this.heroGoldLight,
    required this.heroAmber,
    required this.heroAmberDeep,
    required this.goldLight,
    required this.goldMid,
    required this.goldDeep,
    required this.goldDark,
    required this.goldInk,
    required this.manuscriptCream,
    required this.keyholeInk,
    required this.parchmentTop,
    required this.parchmentBottom,
    required this.inkBrown,
    required this.inkBrownDeep,
    required this.sealGreen,
    required this.sealGreenDeep,
    required this.errRimLight,
    required this.errRimDark,
    required this.errRose,
    required this.errStroke,
  });

  static const AppColorsTheme light = AppColorsTheme(
    textPrimary: AppColors.darkOlive,
    textSecondary: AppColors.dustyOlive,
    textTertiary: AppColors.tobacco,
    textPlaceholder: AppColors.dune,
    textInverse: AppColors.ivory,
    textArabic: AppColors.date,
    dateSoft: AppColors.dateSoft,
    borderSubtle: AppColors.sand,
    borderDefault: AppColors.dune,
    borderStrong: AppColors.date,
    canvas: AppColors.ivory,
    canvasRaised: AppColors.sand,
    accent: AppColors.amber,
    accentSoft: AppColors.amberSoft,
    accentDeep: AppColors.amberDeep,
    olive: AppColors.olive,
    oliveDeep: AppColors.oliveDeep,
    oliveSoft: AppColors.oliveSoft,
    oliveLeaf: AppColors.oliveLeaf,
    ctaTop: AppColors.oliveSoft,
    ctaMid: AppColors.olive,
    ctaBottom: AppColors.oliveDeep,
    onCta: AppColors.ivory,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14F4ECD8),
    overlayDark: Color(0x147A4A29),
    backdropTop: AppColors.creamLight,
    backdropMid: AppColors.creamSand,
    backdropBottom: AppColors.creamDeep,
    desertGradientTop: AppColors.ivoryLight,
    desertGradientMid: AppColors.sandLight,
    desertGradientBottom: AppColors.duneLight,
    desertVeil: AppColors.ivoryLight,
    desertPatternTint: AppColors.ivory,
    creamSurfaceTop: AppColors.creamMid,
    creamSurfaceBottom: AppColors.creamDeep,
    cardSurface: Color(0x8CFFFFFF),
    inputSurface: AppColors.white,
    dialogBorderTop: AppColors.creamBorderDark,
    dialogBorderBottom: AppColors.creamBorderLight,
    sheetSurface: AppColors.paperSand,
    warningSurface: AppColors.roseBlush,
    ticketCloseSurface: AppColors.ticketCloseSurfaceLight,
    ticketCloseBorder: AppColors.ticketCloseBorderLight,
    heroSurfaceTop: AppColors.olive,
    heroSurfaceMid: AppColors.oliveDeep,
    heroSurfaceBottom: AppColors.oliveAbyss,
    heroShadow: AppColors.shadowDeep,
    heroInk: AppColors.ivory,
    heroGlow: AppColors.amberGlow,
    heroGold: AppColors.amberGlow,
    heroGoldLight: AppColors.amberLight,
    heroAmber: AppColors.discGoldLo,
    heroAmberDeep: AppColors.amberDeep,
    goldLight: AppColors.flameLight,
    goldMid: AppColors.goldMid,
    goldDeep: AppColors.goldDeep,
    goldDark: AppColors.goldDark,
    goldInk: AppColors.manuscriptInk,
    manuscriptCream: AppColors.creamLight,
    keyholeInk: AppColors.date,
    parchmentTop: AppColors.parchmentTop,
    parchmentBottom: AppColors.parchmentBottom,
    inkBrown: AppColors.inkBrown,
    inkBrownDeep: AppColors.inkBrownDeep,
    sealGreen: AppColors.sealGreen,
    sealGreenDeep: AppColors.sealGreenDeep,
    errRimLight: AppColors.errRimLight,
    errRimDark: AppColors.errRimDark,
    errRose: AppColors.roseBlush,
    errStroke: AppColors.errStroke,
  );

  static const AppColorsTheme dark = AppColorsTheme(
    textPrimary: DateEmber.ivory,
    textSecondary: DateEmber.txtMute,
    textTertiary: DateEmber.txtFaint,
    textPlaceholder: AppColors.ivory40,
    textInverse: DateEmber.canvas,
    textArabic: DateEmber.amber,
    dateSoft: DateEmber.amberLight,
    borderSubtle: DateEmber.hairline,
    borderDefault: AppColors.ivory16,
    borderStrong: AppColors.ivory32,
    canvas: DateEmber.canvas,
    canvasRaised: AppColors.nightRaised,
    accent: DateEmber.amber,
    accentSoft: DateEmber.amberLight,
    accentDeep: DateEmber.amberDeep,
    // Olive is freed to read as IVORY ink on the dark canvas (it drives most
    // headings, body & icons); the green identity is reserved for `success`,
    // avatars & a few accents via `olive`/`oliveLeaf`.
    olive: AppColors.oliveLight,
    oliveDeep: AppColors.ivory,
    oliveSoft: AppColors.ivory78,
    oliveLeaf: AppColors.oliveLeaf,
    ctaTop: AppColors.emberBright,
    ctaMid: AppColors.ember,
    ctaBottom: AppColors.emberDeep,
    onCta: AppColors.ivory,
    success: AppColors.oliveLight,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14F4ECD8),
    overlayDark: Color(0x33000000),
    // Date & Ember vignette: raised brown top → surface mid → base bottom.
    backdropTop: AppColors.canvasNight2,
    backdropMid: AppColors.nightSurface,
    backdropBottom: AppColors.nightLow,
    // Roasted-brown vignette (raised top → surface mid → base bottom) so the
    // auth/splash canvas reads as Date & Ember instead of a light desert sheet.
    // The veil lifts the form area toward the raised surface; the pattern is
    // tinted ivory so the wallpaper reads as faint light line-art on the dark.
    desertGradientTop: AppColors.canvasNight2,
    desertGradientMid: AppColors.nightSurface,
    desertGradientBottom: AppColors.nightLow,
    desertVeil: AppColors.nightRaised,
    desertPatternTint: AppColors.ivory,
    creamSurfaceTop: AppColors.nightHigh,
    creamSurfaceBottom: AppColors.nightRaised,
    cardSurface: AppColors.nightGlass,
    inputSurface: AppColors.nightRaised,
    dialogBorderTop: AppColors.dialogBorderDarkTop,
    dialogBorderBottom: AppColors.dialogBorderDarkBottom,
    sheetSurface: AppColors.canvasNight2,
    warningSurface: AppColors.tobacco,
    // Surface reuses the ivory-glass film; border is olive-ivory at 24%.
    ticketCloseSurface: AppColors.nightGlass,
    ticketCloseBorder: AppColors.ticketCloseBorderDark,
    // Roasted-brown ramp (raised → surface → base) so the hero matches the
    // Date & Ember leaderboard surfaces instead of the light-mode olive.
    // Frosted ivory-glass surface over the shared Date & Ember backdrop, to
    // match the leaderboard summary card.
    heroSurfaceTop: AppColors.ivory06,
    heroSurfaceMid: AppColors.ivory06,
    heroSurfaceBottom: AppColors.ivory02,
    heroShadow: AppColors.black,
    heroInk: AppColors.ivory,
    heroGlow: AppColors.amberGlow,
    heroGold: AppColors.amberGlow,
    heroGoldLight: AppColors.amberLight,
    heroAmber: AppColors.discGoldLo,
    heroAmberDeep: AppColors.amberDeep,
    goldLight: AppColors.flameLight,
    goldMid: AppColors.goldMid,
    goldDeep: AppColors.goldDeep,
    goldDark: AppColors.goldDark,
    goldInk: AppColors.manuscriptInk,
    manuscriptCream: AppColors.creamLight,
    keyholeInk: AppColors.date,
    parchmentTop: AppColors.parchmentTop,
    parchmentBottom: AppColors.parchmentBottom,
    inkBrown: AppColors.inkBrown,
    inkBrownDeep: AppColors.inkBrownDeep,
    sealGreen: AppColors.sealGreen,
    sealGreenDeep: AppColors.sealGreenDeep,
    errRimLight: AppColors.errRimLight,
    errRimDark: AppColors.errRimDark,
    errRose: AppColors.roseBlush,
    errStroke: AppColors.errStroke,
  );

  @override
  AppColorsTheme copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? textInverse,
    Color? textArabic,
    Color? dateSoft,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? canvas,
    Color? canvasRaised,
    Color? accent,
    Color? accentSoft,
    Color? accentDeep,
    Color? olive,
    Color? oliveDeep,
    Color? oliveSoft,
    Color? oliveLeaf,
    Color? ctaTop,
    Color? ctaMid,
    Color? ctaBottom,
    Color? onCta,
    Color? success,
    Color? warning,
    Color? info,
    Color? overlayLight,
    Color? overlayDark,
    Color? backdropTop,
    Color? backdropMid,
    Color? backdropBottom,
    Color? desertGradientTop,
    Color? desertGradientMid,
    Color? desertGradientBottom,
    Color? desertVeil,
    Color? desertPatternTint,
    Color? creamSurfaceTop,
    Color? creamSurfaceBottom,
    Color? cardSurface,
    Color? inputSurface,
    Color? dialogBorderTop,
    Color? dialogBorderBottom,
    Color? sheetSurface,
    Color? warningSurface,
    Color? ticketCloseSurface,
    Color? ticketCloseBorder,
    Color? heroSurfaceTop,
    Color? heroSurfaceMid,
    Color? heroSurfaceBottom,
    Color? heroShadow,
    Color? heroInk,
    Color? heroGlow,
    Color? heroGold,
    Color? heroGoldLight,
    Color? heroAmber,
    Color? heroAmberDeep,
    Color? goldLight,
    Color? goldMid,
    Color? goldDeep,
    Color? goldDark,
    Color? goldInk,
    Color? manuscriptCream,
    Color? keyholeInk,
    Color? parchmentTop,
    Color? parchmentBottom,
    Color? inkBrown,
    Color? inkBrownDeep,
    Color? sealGreen,
    Color? sealGreenDeep,
    Color? errRimLight,
    Color? errRimDark,
    Color? errRose,
    Color? errStroke,
  }) => AppColorsTheme(
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textPlaceholder: textPlaceholder ?? this.textPlaceholder,
    textInverse: textInverse ?? this.textInverse,
    textArabic: textArabic ?? this.textArabic,
    dateSoft: dateSoft ?? this.dateSoft,
    borderSubtle: borderSubtle ?? this.borderSubtle,
    borderDefault: borderDefault ?? this.borderDefault,
    borderStrong: borderStrong ?? this.borderStrong,
    canvas: canvas ?? this.canvas,
    canvasRaised: canvasRaised ?? this.canvasRaised,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    accentDeep: accentDeep ?? this.accentDeep,
    olive: olive ?? this.olive,
    oliveDeep: oliveDeep ?? this.oliveDeep,
    oliveSoft: oliveSoft ?? this.oliveSoft,
    oliveLeaf: oliveLeaf ?? this.oliveLeaf,
    ctaTop: ctaTop ?? this.ctaTop,
    ctaMid: ctaMid ?? this.ctaMid,
    ctaBottom: ctaBottom ?? this.ctaBottom,
    onCta: onCta ?? this.onCta,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    overlayLight: overlayLight ?? this.overlayLight,
    overlayDark: overlayDark ?? this.overlayDark,
    backdropTop: backdropTop ?? this.backdropTop,
    backdropMid: backdropMid ?? this.backdropMid,
    backdropBottom: backdropBottom ?? this.backdropBottom,
    desertGradientTop: desertGradientTop ?? this.desertGradientTop,
    desertGradientMid: desertGradientMid ?? this.desertGradientMid,
    desertGradientBottom: desertGradientBottom ?? this.desertGradientBottom,
    desertVeil: desertVeil ?? this.desertVeil,
    desertPatternTint: desertPatternTint ?? this.desertPatternTint,
    creamSurfaceTop: creamSurfaceTop ?? this.creamSurfaceTop,
    creamSurfaceBottom: creamSurfaceBottom ?? this.creamSurfaceBottom,
    cardSurface: cardSurface ?? this.cardSurface,
    inputSurface: inputSurface ?? this.inputSurface,
    dialogBorderTop: dialogBorderTop ?? this.dialogBorderTop,
    dialogBorderBottom: dialogBorderBottom ?? this.dialogBorderBottom,
    sheetSurface: sheetSurface ?? this.sheetSurface,
    warningSurface: warningSurface ?? this.warningSurface,
    ticketCloseSurface: ticketCloseSurface ?? this.ticketCloseSurface,
    ticketCloseBorder: ticketCloseBorder ?? this.ticketCloseBorder,
    heroSurfaceTop: heroSurfaceTop ?? this.heroSurfaceTop,
    heroSurfaceMid: heroSurfaceMid ?? this.heroSurfaceMid,
    heroSurfaceBottom: heroSurfaceBottom ?? this.heroSurfaceBottom,
    heroShadow: heroShadow ?? this.heroShadow,
    heroInk: heroInk ?? this.heroInk,
    heroGlow: heroGlow ?? this.heroGlow,
    heroGold: heroGold ?? this.heroGold,
    heroGoldLight: heroGoldLight ?? this.heroGoldLight,
    heroAmber: heroAmber ?? this.heroAmber,
    heroAmberDeep: heroAmberDeep ?? this.heroAmberDeep,
    goldLight: goldLight ?? this.goldLight,
    goldMid: goldMid ?? this.goldMid,
    goldDeep: goldDeep ?? this.goldDeep,
    goldDark: goldDark ?? this.goldDark,
    goldInk: goldInk ?? this.goldInk,
    manuscriptCream: manuscriptCream ?? this.manuscriptCream,
    keyholeInk: keyholeInk ?? this.keyholeInk,
    parchmentTop: parchmentTop ?? this.parchmentTop,
    parchmentBottom: parchmentBottom ?? this.parchmentBottom,
    inkBrown: inkBrown ?? this.inkBrown,
    inkBrownDeep: inkBrownDeep ?? this.inkBrownDeep,
    sealGreen: sealGreen ?? this.sealGreen,
    sealGreenDeep: sealGreenDeep ?? this.sealGreenDeep,
    errRimLight: errRimLight ?? this.errRimLight,
    errRimDark: errRimDark ?? this.errRimDark,
    errRose: errRose ?? this.errRose,
    errStroke: errStroke ?? this.errStroke,
  );

  @override
  AppColorsTheme lerp(ThemeExtension<AppColorsTheme>? other, double t) {
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textArabic: Color.lerp(textArabic, other.textArabic, t)!,
      dateSoft: Color.lerp(dateSoft, other.dateSoft, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      canvasRaised: Color.lerp(canvasRaised, other.canvasRaised, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      olive: Color.lerp(olive, other.olive, t)!,
      oliveDeep: Color.lerp(oliveDeep, other.oliveDeep, t)!,
      oliveSoft: Color.lerp(oliveSoft, other.oliveSoft, t)!,
      oliveLeaf: Color.lerp(oliveLeaf, other.oliveLeaf, t)!,
      ctaTop: Color.lerp(ctaTop, other.ctaTop, t)!,
      ctaMid: Color.lerp(ctaMid, other.ctaMid, t)!,
      ctaBottom: Color.lerp(ctaBottom, other.ctaBottom, t)!,
      onCta: Color.lerp(onCta, other.onCta, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      overlayLight: Color.lerp(overlayLight, other.overlayLight, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
      backdropTop: Color.lerp(backdropTop, other.backdropTop, t)!,
      backdropMid: Color.lerp(backdropMid, other.backdropMid, t)!,
      backdropBottom: Color.lerp(backdropBottom, other.backdropBottom, t)!,
      desertGradientTop: Color.lerp(
        desertGradientTop,
        other.desertGradientTop,
        t,
      )!,
      desertGradientMid: Color.lerp(
        desertGradientMid,
        other.desertGradientMid,
        t,
      )!,
      desertGradientBottom: Color.lerp(
        desertGradientBottom,
        other.desertGradientBottom,
        t,
      )!,
      desertVeil: Color.lerp(desertVeil, other.desertVeil, t)!,
      desertPatternTint: Color.lerp(
        desertPatternTint,
        other.desertPatternTint,
        t,
      )!,
      creamSurfaceTop: Color.lerp(creamSurfaceTop, other.creamSurfaceTop, t)!,
      creamSurfaceBottom: Color.lerp(
        creamSurfaceBottom,
        other.creamSurfaceBottom,
        t,
      )!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      inputSurface: Color.lerp(inputSurface, other.inputSurface, t)!,
      dialogBorderTop: Color.lerp(dialogBorderTop, other.dialogBorderTop, t)!,
      dialogBorderBottom: Color.lerp(
        dialogBorderBottom,
        other.dialogBorderBottom,
        t,
      )!,
      sheetSurface: Color.lerp(sheetSurface, other.sheetSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      ticketCloseSurface: Color.lerp(
        ticketCloseSurface,
        other.ticketCloseSurface,
        t,
      )!,
      ticketCloseBorder: Color.lerp(
        ticketCloseBorder,
        other.ticketCloseBorder,
        t,
      )!,
      heroSurfaceTop: Color.lerp(heroSurfaceTop, other.heroSurfaceTop, t)!,
      heroSurfaceMid: Color.lerp(heroSurfaceMid, other.heroSurfaceMid, t)!,
      heroSurfaceBottom: Color.lerp(
        heroSurfaceBottom,
        other.heroSurfaceBottom,
        t,
      )!,
      heroShadow: Color.lerp(heroShadow, other.heroShadow, t)!,
      heroInk: Color.lerp(heroInk, other.heroInk, t)!,
      heroGlow: Color.lerp(heroGlow, other.heroGlow, t)!,
      heroGold: Color.lerp(heroGold, other.heroGold, t)!,
      heroGoldLight: Color.lerp(heroGoldLight, other.heroGoldLight, t)!,
      heroAmber: Color.lerp(heroAmber, other.heroAmber, t)!,
      heroAmberDeep: Color.lerp(heroAmberDeep, other.heroAmberDeep, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldMid: Color.lerp(goldMid, other.goldMid, t)!,
      goldDeep: Color.lerp(goldDeep, other.goldDeep, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      goldInk: Color.lerp(goldInk, other.goldInk, t)!,
      manuscriptCream: Color.lerp(manuscriptCream, other.manuscriptCream, t)!,
      keyholeInk: Color.lerp(keyholeInk, other.keyholeInk, t)!,
      parchmentTop: Color.lerp(parchmentTop, other.parchmentTop, t)!,
      parchmentBottom: Color.lerp(parchmentBottom, other.parchmentBottom, t)!,
      inkBrown: Color.lerp(inkBrown, other.inkBrown, t)!,
      inkBrownDeep: Color.lerp(inkBrownDeep, other.inkBrownDeep, t)!,
      sealGreen: Color.lerp(sealGreen, other.sealGreen, t)!,
      sealGreenDeep: Color.lerp(sealGreenDeep, other.sealGreenDeep, t)!,
      errRimLight: Color.lerp(errRimLight, other.errRimLight, t)!,
      errRimDark: Color.lerp(errRimDark, other.errRimDark, t)!,
      errRose: Color.lerp(errRose, other.errRose, t)!,
      errStroke: Color.lerp(errStroke, other.errStroke, t)!,
    );
  }
}

class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme light = ColorScheme.light(
    primary: AppColors.amber,
    onPrimary: AppColors.ivory,
    primaryContainer: AppColors.sand,
    onPrimaryContainer: AppColors.date,
    secondary: AppColors.date,
    onSecondary: AppColors.ivory,
    secondaryContainer: AppColors.dune,
    onSecondaryContainer: AppColors.dateDeep,
    tertiary: AppColors.darkOlive,
    onTertiary: AppColors.ivory,
    error: AppColors.error,
    onError: AppColors.ivory,
    surface: AppColors.ivory,
    onSurface: AppColors.darkOlive,
    onSurfaceVariant: AppColors.dustyOlive,
    surfaceContainerLowest: AppColors.ivory,
    surfaceContainerLow: AppColors.sand,
    surfaceContainer: AppColors.sand,
    surfaceContainerHigh: AppColors.dune,
    surfaceContainerHighest: AppColors.dune,
    outline: AppColors.dune,
    outlineVariant: AppColors.sand,
    inverseSurface: AppColors.dateDeep,
    onInverseSurface: AppColors.ivory,
    inversePrimary: AppColors.amberSoft,
    shadow: AppColors.dateDeep,
    scrim: AppColors.dateDeep,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: DateEmber.amber,
    onPrimary: DateEmber.canvas,
    primaryContainer: DateEmber.raised,
    onPrimaryContainer: DateEmber.amberLight,
    secondary: DateEmber.amberLight,
    onSecondary: DateEmber.canvas,
    secondaryContainer: DateEmber.raised,
    onSecondaryContainer: DateEmber.ivory,
    tertiary: DateEmber.olive,
    onTertiary: DateEmber.canvas,
    error: AppColors.error,
    onError: AppColors.ivory,
    surface: DateEmber.canvas,
    onSurface: DateEmber.ivory,
    onSurfaceVariant: DateEmber.txtMute,
    surfaceContainerLowest: AppColors.nightLow,
    surfaceContainerLow: AppColors.canvasNight2,
    surfaceContainer: AppColors.nightRaised,
    surfaceContainerHigh: AppColors.nightHigh,
    surfaceContainerHighest: AppColors.nightTop,
    outline: AppColors.nightOutline,
    outlineVariant: AppColors.nightOutlineVariant,
    inverseSurface: AppColors.ivory,
    onInverseSurface: AppColors.canvasNight,
    inversePrimary: AppColors.amberDeep,
    shadow: AppColors.black,
    scrim: AppColors.black,
  );
}
