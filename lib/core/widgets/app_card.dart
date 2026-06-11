import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The visual recipe a card paints with.
enum AppCardVariant {
  /// Solid translucent surface, hairline border, single soft lift. The default
  /// list / feed / notification card.
  flat,

  /// Subtle raised gradient, faint border, two-layer warm lift. For primary or
  /// content-forward cards (questions, categories, success panels).
  elevated,

  /// Frosted translucent fill, no shadow, olive hairline. For pickers and
  /// selection grids (roles, profiles, kids).
  glass,

  /// Accent-tinted flat fill, no shadow. For inline feedback / receipt panels.
  tinted,
}

/// A single reusable card surface for the whole app. Pick a variant via the
/// named constructors; every variant resolves its colours, radius, border and
/// shadow from the theme ([AppColorsTheme] + [ZaadRadii] + [ZaadShadows]) so the
/// surface language stays consistent and theme-aware.
///
/// ```dart
/// AppCard.flat(child: Text('hi'))
/// AppCard.elevated(tint: colors.olive, child: ...)
/// AppCard.glass(onTap: ..., selected: isSelected, child: ...)
/// AppCard.tinted(tint: colors.accent, child: ...)
/// ```
///
/// Any visual default can be overridden with [color], [gradient], [radius],
/// [border], [boxShadow] and [padding] for the handful of bespoke cases that
/// need to deviate without dropping back to a raw [Container].
class AppCard extends StatelessWidget {
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.onTap,
    this.selected = false,
    this.tint,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  }) : variant = AppCardVariant.flat;

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.onTap,
    this.selected = false,
    this.tint,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  }) : variant = AppCardVariant.elevated;

  const AppCard.glass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.onTap,
    this.selected = false,
    this.tint,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  }) : variant = AppCardVariant.glass;

  const AppCard.tinted({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.onTap,
    this.selected = false,
    this.tint,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  }) : variant = AppCardVariant.tinted;

  final AppCardVariant variant;
  final Widget child;

  /// Inner padding. Defaults per variant (see [_defaultPadding]).
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Corner radius. Defaults per variant (see [_defaultRadius]).
  final double? radius;

  /// When non-null the whole card becomes tappable (with an ink ripple clipped
  /// to the corners).
  final VoidCallback? onTap;

  /// Drives the selected treatment (accent border + accent glow) for the
  /// interactive variants.
  final bool selected;

  /// The card's identity colour — tunes the gradient/border/shadow tint for the
  /// [AppCardVariant.elevated]/[AppCardVariant.tinted] variants and the selected
  /// state. Defaults to the theme accent.
  final Color? tint;

  /// Overrides — escape hatches for bespoke cards.
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  final double? width;
  final double? height;
  final Clip clipBehavior;

  EdgeInsetsGeometry get _defaultPadding => switch (variant) {
    AppCardVariant.flat => const EdgeInsets.all(14),
    AppCardVariant.elevated => const EdgeInsets.all(18),
    AppCardVariant.glass => const EdgeInsets.all(14),
    AppCardVariant.tinted => const EdgeInsets.all(16),
  };

  double get _defaultRadius => switch (variant) {
    AppCardVariant.flat => ZaadRadii.card, // 20
    AppCardVariant.elevated => ZaadRadii.xxl, // 22
    AppCardVariant.glass => ZaadRadii.xxl, // 22
    AppCardVariant.tinted => ZaadRadii.xl, // 18
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = this.tint ?? colors.accent;
    final br = BorderRadius.circular(radius ?? _defaultRadius);

    final decoration = BoxDecoration(
      color: color ?? _resolveColor(colors, tint),
      gradient: color != null ? null : (gradient ?? _resolveGradient(colors, tint)),
      borderRadius: br,
      border: border ?? _resolveBorder(colors, tint),
      boxShadow: boxShadow ?? _resolveShadow(colors, tint),
    );

    Widget content = Padding(
      padding: padding ?? _defaultPadding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: decoration,
      child: content,
    );
  }

  // ── Per-variant resolvers ──────────────────────────────────────────────────

  Color? _resolveColor(AppColorsTheme c, Color tint) => switch (variant) {
    AppCardVariant.flat => c.cardSurface,
    AppCardVariant.glass => c.cardSurface,
    AppCardVariant.tinted => Color.lerp(c.canvasRaised, tint, 0.06),
    AppCardVariant.elevated => null, // painted by the gradient
  };

  Gradient? _resolveGradient(AppColorsTheme c, Color tint) =>
      switch (variant) {
        AppCardVariant.elevated => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.canvasRaised,
            Color.lerp(c.canvas, tint, 0.06)!,
          ],
        ),
        _ => null,
      };

  BoxBorder _resolveBorder(AppColorsTheme c, Color tint) {
    if (selected) {
      return Border.all(color: tint.withValues(alpha: 0.55), width: 1.6);
    }
    return switch (variant) {
      AppCardVariant.flat => Border.all(
        color: c.olive.withValues(alpha: 0.16),
        width: 1.2,
      ),
      AppCardVariant.elevated => Border.all(
        color: tint.withValues(alpha: 0.18),
        width: 0.8,
      ),
      AppCardVariant.glass => Border.all(
        color: c.oliveSoft.withValues(alpha: 0.22),
        width: 1.5,
      ),
      AppCardVariant.tinted => Border.all(
        color: tint.withValues(alpha: 0.30),
        width: 0.8,
      ),
    };
  }

  List<BoxShadow>? _resolveShadow(AppColorsTheme c, Color tint) {
    if (selected) return ZaadShadows.selected(c, tint: tint);
    return switch (variant) {
      AppCardVariant.flat => ZaadShadows.card(c),
      AppCardVariant.elevated => ZaadShadows.elevated(c, tint: tint),
      AppCardVariant.glass => null,
      AppCardVariant.tinted => null,
    };
  }
}
