import 'package:flutter/widgets.dart';

/// Canonical corner-radius scale for the app.
///
/// Pick the smallest token that still expresses the role. Don't introduce
/// fresh literal values in feature code — extend this scale instead.
///
/// Quick guide:
/// - [xs] (8): inline chips, tight inputs.
/// - [sm] (10): mini fields, small tiles.
/// - [md] (12): dialog CTAs, dialog inputs, compact buttons.
/// - [lg] (14): primary buttons and standard text fields (default).
/// - [xl] (18): cards, kid cards, list rows.
/// - [xxl] (22): hero cards, role-pick tiles.
/// - [card] (20): section cards on profile.
/// - [dialog] (28): [CustomDialog] outer shell.
/// - [pill] (999): fully rounded pills.
class ZaadRadii {
  ZaadRadii._();

  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double card = 20;
  static const double xl = 18;
  static const double xxl = 22;
  static const double dialog = 28;
  static const double pill = 999;

  // Convenience BorderRadius constants for the most common cases.
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius dialogAll = BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
