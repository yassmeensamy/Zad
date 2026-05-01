import 'package:flutter/widgets.dart';

/// Canonical semantic text styles for the app.
///
/// Color is intentionally omitted — resolve at the call site via
/// `.copyWith(color: context.appColors.X)`. Pick the closest semantic role
/// rather than a raw `fontSize` to keep the visual rhythm consistent.
///
/// Roles:
/// - [eyebrow] / [eyebrowSm] — uppercase kicker above a heading or section.
/// - [titleHero] — auth & onboarding screen headlines.
/// - [titleAccent] — dialog header titles (eyebrow + accent + rule).
/// - [sectionLabel] — small label heading a list section.
/// - [fieldLabel] — tiny label inside an inline-labelled input.
/// - [ctaCompact] — letterspaced label on a compact dialog CTA.
/// - [bodyLarge] / [bodyMedium] / [bodySmall] — running copy.
/// - [caption] / [captionSmall] — meta / helper text.
class ZaadType {
  ZaadType._();

  // ── Display / hero ────────────────────────────────────────────────
  static const TextStyle titleHero = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w300,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const TextStyle titleAccent = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.3,
  );

  // ── Eyebrow / kicker ──────────────────────────────────────────────
  /// Standard kicker — used above onboarding & screen headlines.
  static const TextStyle eyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 3.2,
    height: 1.4,
  );

  /// Smaller kicker — used inside dialog headers.
  static const TextStyle eyebrowSm = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.4,
    height: 1.4,
  );

  // ── Section / labels ──────────────────────────────────────────────
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
    height: 1.4,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 8.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.7,
    height: 1.4,
  );

  // ── CTA labels ────────────────────────────────────────────────────
  /// Letterspaced label used on dialog/modal compact CTAs.
  static const TextStyle ctaCompact = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.16,
    height: 1.4,
  );

  /// Standard primary-button label.
  static const TextStyle ctaLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.4,
  );

  // ── Body copy ─────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Captions / meta ───────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ── App-bar / nav ─────────────────────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static const TextStyle appBarSubtitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static const TextStyle navLabelActive = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
}
