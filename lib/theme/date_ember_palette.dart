import 'package:flutter/material.dart';

/// The **Date & Ember** palette — the complete set of colours extracted from
/// the Date & Ember designs (leaderboard + profile).
///
/// This is the single source of truth for the app's dark theme *and* the
/// Date & Ember showcase screens. Roasted-brown depths, gold/amber accents, an
/// ember CTA and ivory ink. The app dark theme ([AppColors] night tokens +
/// `AppColorsTheme.dark`) references these values, and the showcase screens
/// import this class directly — so the whole app shares one palette.
class DateEmber {
  const DateEmber._();

  // ── Roasted-brown depths (vignette stops + page canvas) ──────────────────
  static const Color base = Color(0xFF0E0905); // darkest — roasted near-black
  static const Color surface = Color(0xFF1A120B); // mid surface brown
  static const Color raised = Color(0xFF271A10); // top glow / raised surface
  static const Color canvas = Color(0xFF140F0A); // page background

  // ── Ivory ink (text + hairlines over the dark canvas) ────────────────────
  static const Color ivory = Color(0xFFF4ECD8); // primary text
  static const Color txtMute = Color(0x9EF4ECD8); // ivory @ 0.62 — secondary
  static const Color txtFaint = Color(0x66F4ECD8); // ivory @ 0.40 — tertiary
  static const Color hairline = Color(0x14F4ECD8); // ivory @ 0.08 — dividers

  // ── Gold / amber family ──────────────────────────────────────────────────
  static const Color amber = Color(0xFFE0A560);
  static const Color amberLight = Color(0xFFF1C57A);
  static const Color amberDeep = Color(0xFFA6622A);
  static const Color washAmber = Color(0xFFE1A560); // rgba(225,165,96,…)
  static const Color glassBorder = Color(0x33E1A560); // washAmber @ 0.20

  // ── Ember (CTA + "on fire") ──────────────────────────────────────────────
  static const Color ember = Color(0xFFC9512B); // CTA base
  static const Color emberLight = Color(0xFFE07A48); // CTA gradient top
  static const Color emberDeep = Color(0xFFA53E1E); // CTA gradient bottom
  static const Color emberInk = Color(0xFF1A0E06); // ink over ember fills

  // ── Success olive ────────────────────────────────────────────────────────
  static const Color olive = Color(0xFF7A8A5A);

  // ── Metallic disc ramps (avatars / podium) ───────────────────────────────
  static const Color goldHi = Color(0xFFF1C57A);
  static const Color goldMid = Color(0xFFE0A560);
  static const Color goldLo = Color(0xFFA6622A);
  static const Color goldInk = Color(0xFF2A1B0A);

  static const Color silverHi = Color(0xFFF4EBDC);
  static const Color silverMid = Color(0xFFCDBFA6);
  static const Color silverLo = Color(0xFF8A7456);

  static const Color bronzeHi = Color(0xFFE8A877);
  static const Color bronzeMid = Color(0xFFC9512B);
  static const Color bronzeLo = Color(0xFF7A2E15);
  static const Color bronzeInk = Color(0xFF2A1206);

  static const Color oliveHi = Color(0xFFA6B584);
  static const Color oliveMid = Color(0xFF7A8A5A);
  static const Color oliveLo = Color(0xFF42502E);
  static const Color oliveInk = Color(0xFF1A2010);

  static const Color dateHi = Color(0xFFD9A878);
  static const Color dateMid = Color(0xFFA6622A);
  static const Color dateLo = Color(0xFF5E3115);
}
