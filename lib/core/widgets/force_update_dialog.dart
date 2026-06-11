import 'dart:ui' as ui show TextDirection;
import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// App-update prompt in the *Date & Ember* treatment, adapted to both light and
/// dark themes and driving **force** and **optional** updates from one design.
///
/// A gilded medallion with a bobbing arrow and version tag, a status pill, a
/// current → latest version compare, and a single gold "Update now" CTA — over
/// a blurred, dimmed app.
///
/// * **Force** ([show] with `isForceUpdate: true`, or [overlay]) — blocking:
///   no close, no "Later", no barrier tap-out, no system back. The only way
///   forward is to update. A "this update is required" note sits under the CTA.
/// * **Optional** ([show] with `isForceUpdate: false`) — dismissible: barrier
///   tap-out and system back are allowed, and a "Later" action sits beside the
///   CTA.
///
/// Every colour resolves from [AppColorsTheme] (`context.appColors`): the
/// `update*` tokens shift the card surface, scrim, recess and hairline between
/// the cream parchment (light) and the roasted-brown canvas (dark), while the
/// medallion gold and ember accents come from [AppColors] and stay
/// constant — they're the signature of the moment and read on either canvas.
class AppUpdateDialog {
  const AppUpdateDialog._();

  /// Imperative prompt pushed onto the navigator. Defaults to a blocking
  /// force-update; pass `isForceUpdate: false` for the dismissible variant.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onUpdate,
    bool isForceUpdate = true,
    String? currentVersion,
    String? newVersion,
    String? versionTag,
    String? releaseNotes,
    VoidCallback? onLater,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: !isForceUpdate,
      barrierLabel: _pillKey(isForceUpdate).tr(),
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, _, _) => PopScope(
        canPop: !isForceUpdate,
        child: _UpdateScaffold(
          isForceUpdate: isForceUpdate,
          onUpdate: onUpdate,
          onLater: onLater ?? () => Navigator.of(context).maybePop(),
          currentVersion: currentVersion,
          newVersion: newVersion,
          versionTag: _resolveTag(versionTag, newVersion),
          releaseNotes: releaseNotes,
        ),
      ),
      transitionBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: Transform.scale(
            scale: 0.92 + 0.08 * curved.value,
            child: child,
          ),
        );
      },
    );
  }

  /// Persistent, route-independent force-update overlay. Rendered directly in
  /// `MaterialApp.router`'s `builder` (above the router's Navigator) so
  /// go_router page changes can't tear it down the way an imperative [show]
  /// pushed onto the router navigator would. Always blocking.
  static Widget overlay({
    required VoidCallback onUpdate,
    String? currentVersion,
    String? newVersion,
    String? versionTag,
    String? releaseNotes,
  }) {
    return PopScope(
      canPop: false,
      child: _UpdateScaffold(
        isForceUpdate: true,
        onUpdate: onUpdate,
        onLater: null,
        currentVersion: currentVersion,
        newVersion: newVersion,
        versionTag: _resolveTag(versionTag, newVersion),
        releaseNotes: releaseNotes,
      ),
    );
  }

  static String _pillKey(bool isForceUpdate) =>
      isForceUpdate ? 'update.required_pill' : 'update.available_pill';

  /// `v3.0` from `3.0.0`; falls back to an explicit tag, or null to hide it.
  static String? _resolveTag(String? versionTag, String? newVersion) {
    if (versionTag != null) return versionTag;
    if (newVersion == null || newVersion.isEmpty) return null;
    return 'v${newVersion.split('.').first}.0';
  }
}

/// Full-screen layer: blurred + darkened scrim over the app, with the dialog
/// card centred on top. Resolves [AppColorsTheme] once and threads it down so
/// leaf widgets stay pure (no repeated `context.appColors` lookups).
class _UpdateScaffold extends StatelessWidget {
  const _UpdateScaffold({
    required this.isForceUpdate,
    required this.onUpdate,
    required this.onLater,
    required this.currentVersion,
    required this.newVersion,
    required this.versionTag,
    required this.releaseNotes,
  });

  final bool isForceUpdate;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;
  final String? currentVersion;
  final String? newVersion;
  final String? versionTag;
  final String? releaseNotes;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // A transparent Material so the dialog's Text widgets inherit a text style
    // (without it, text renders with the debug yellow underline since
    // showGeneralDialog gives us no Material/Scaffold ancestor).
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blurred, dimmed app behind. For the optional variant a barrier tap
          // dismisses; for force it's inert.
          Positioned.fill(
            child: GestureDetector(
              onTap: isForceUpdate ? null : onLater,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.1),
                      radius: 1.0,
                      colors: [colors.updateScrimInner, colors.updateScrimOuter],
                      stops: const [0.4, 0.95],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Vertically + horizontally centred, but still scrollable when the
          // card is taller than the viewport (small screens / large text).
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Center(
                      child: _UpdateCard(
                        colors: colors,
                        isForceUpdate: isForceUpdate,
                        onUpdate: onUpdate,
                        onLater: onLater,
                        currentVersion: currentVersion,
                        newVersion: newVersion,
                        versionTag: versionTag,
                        releaseNotes: releaseNotes,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    required this.colors,
    required this.isForceUpdate,
    required this.onUpdate,
    required this.onLater,
    required this.currentVersion,
    required this.newVersion,
    required this.versionTag,
    required this.releaseNotes,
  });

  final AppColorsTheme colors;
  final bool isForceUpdate;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;
  final String? currentVersion;
  final String? newVersion;
  final String? versionTag;
  final String? releaseNotes;

  @override
  Widget build(BuildContext context) {
    final appName = 'app_name'.tr();
    final notes = releaseNotes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;
    final showVersions = currentVersion != null && newVersion != null;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Card body ──────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(top: 52),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.updateSurfaceTop, colors.updateSurfaceBottom],
            ),
            border: Border.all(color: colors.updateBorder),
            boxShadow: [
              BoxShadow(
                color: colors.updateShadow,
                blurRadius: 80,
                offset: const Offset(0, 40),
              ),
            ],
          ),
          child: Stack(
            children: [
              // amber glow wash at the top of the card
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 220,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -1.0),
                        radius: 1.1,
                        colors: [
                          colors.accent.withValues(alpha: 0.22),
                          colors.accent.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.52],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusPill(colors: colors, isForceUpdate: isForceUpdate),
                    const SizedBox(height: 12),
                    _Headline(appName: appName, colors: colors),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      'update.arabic_required',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontFamily: 'ElMessiri',
                        fontWeight: FontWeight.w700,
                        color: colors.textArabic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ResponsiveText(
                      // Real store release notes pass straight through; otherwise
                      // fall back to the generic description key.
                      hasNotes ? notes : 'update.force_description',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (showVersions) ...[
                      const SizedBox(height: 18),
                      _VersionCompare(
                        colors: colors,
                        currentVersion: currentVersion!,
                        newVersion: newVersion!,
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (isForceUpdate) ...[
                      _UpdateCta(colors: colors, onTap: onUpdate),
                      const SizedBox(height: 12),
                      _RequiredNote(appName: appName, colors: colors),
                    ] else
                      // Optional update: secondary "Later" and primary "Update"
                      // sit side by side, the CTA taking the larger share.
                      // Pinned LTR so "Later" stays on the left in RTL locales.
                      Row(
                        textDirection: ui.TextDirection.ltr,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _LaterButton(colors: colors, onTap: onLater),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _UpdateCta(colors: colors, onTap: onUpdate),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Overlapping badge ──────────────────────────────────────────────
        _Badge(versionTag: versionTag, colors: colors),
      ],
    );
  }
}

/// Pulsing-halo gold disc with a bobbing up-arrow and an optional version tag.
class _Badge extends StatefulWidget {
  const _Badge({required this.versionTag, required this.colors});

  final String? versionTag;
  final AppColorsTheme colors;

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final glow = colors.accent;
    final tag = widget.versionTag;
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // halo
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) {
              final t = Curves.easeInOut.transform(_pulse.value);
              return Opacity(
                opacity: 0.6 + 0.4 * t,
                child: Transform.scale(
                  scale: 1.0 + 0.08 * t,
                  child: Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glow.withValues(alpha: 0.40),
                          glow.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // gold disc — the gilded medallion is the focal point and reads on
          // both cream and the dark canvas, so its gold ramp is kept constant.
          Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.32, -0.48),
                radius: 1.0,
                colors: [
                  AppColors.medallionHighlight,
                  AppColors.discGoldHi,
                  AppColors.discGoldMid,
                  AppColors.discGoldLo,
                ],
                stops: [0.0, 0.38, 0.62, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.discGoldHi.withValues(alpha: 0.6),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppColors.ember.withValues(alpha: 0.42),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _bob,
              builder: (_, child) {
                final t = Curves.easeInOut.transform(_bob.value);
                return Transform.translate(
                  offset: Offset(0, 2 - 5 * t),
                  child: child,
                );
              },
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 42,
                color: AppColors.medallionInk,
              ),
            ),
          ),
          // version tag — ember pill, kept constant as a brand accent.
          if (tag != null)
            Positioned(
              bottom: -4,
              child: Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.emberBright, AppColors.ember],
                  ),
                  border: Border.all(
                    color: colors.updateSurfaceTop,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ember.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ResponsiveText(
                  tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: AppColors.emberInk,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Status pill above the headline. Force → ember "Update required" with a lock;
/// optional → amber "Update available" with a sparkle.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.colors, required this.isForceUpdate});

  final AppColorsTheme colors;
  final bool isForceUpdate;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    final Color ink;
    final IconData icon;
    final String labelKey;
    if (isForceUpdate) {
      fill = AppColors.ember.withValues(alpha: 0.16);
      border = AppColors.emberBright.withValues(alpha: 0.42);
      ink = AppColors.ember;
      icon = Icons.lock_outline_rounded;
      labelKey = 'update.required_pill';
    } else {
      fill = colors.accent.withValues(alpha: 0.14);
      border = colors.accent.withValues(alpha: 0.40);
      ink = colors.updateBrandAccent;
      icon = Icons.auto_awesome_rounded;
      labelKey = 'update.available_pill';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: fill,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ink),
          const SizedBox(width: 6),
          ResponsiveText(
            labelKey.tr().toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Italic headline with the brand word ({app}) picked out in the accent ink.
/// Kept as [Text.rich] — a multi-style line that [ResponsiveText] can't express.
class _Headline extends StatelessWidget {
  const _Headline({required this.appName, required this.colors});

  final String appName;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.displaySmall.copyWith(
      fontWeight: FontWeight.w400,
      height: 1.1,
      letterSpacing: -0.5,
      color: colors.textPrimary,
    );

    // Split on the {app} placeholder so the brand word renders in amber while
    // the surrounding copy stays in the primary ink — robust across locales.
    final parts = 'update.force_headline'.tr().split('{app}');
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: appName,
            style: TextStyle(color: colors.updateBrandAccent),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: TextAlign.center,
    );
  }
}

class _VersionCompare extends StatelessWidget {
  const _VersionCompare({
    required this.colors,
    required this.currentVersion,
    required this.newVersion,
  });

  final AppColorsTheme colors;
  final String currentVersion;
  final String newVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: colors.updateRecess,
        border: Border.all(color: colors.updateHairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _VersionColumn(
            label: 'update.current'.tr(),
            version: currentVersion,
            strikethrough: true,
            color: colors.textSecondary,
            labelColor: colors.textTertiary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: colors.accent,
            ),
          ),
          _VersionColumn(
            label: 'update.latest'.tr(),
            version: newVersion,
            strikethrough: false,
            color: colors.accent,
            labelColor: colors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  const _VersionColumn({
    required this.label,
    required this.version,
    required this.strikethrough,
    required this.color,
    required this.labelColor,
  });

  final String label;
  final String version;
  final bool strikethrough;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveText(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        ResponsiveText(
          version,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: color,
            decoration: strikethrough
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: AppColors.emberBright.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Shared pill-shaped button shell for both the gold CTA and the outlined
/// "Later" action — same radius, height and label typography, different skin.
/// [overlay] is stacked over the label (the CTA uses it for the shine sweep).
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.decoration,
    required this.label,
    required this.labelColor,
    required this.onTap,
    this.icon,
    this.overlay,
  });

  final BoxDecoration decoration;
  final String label;
  final Color labelColor;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: decoration.copyWith(borderRadius: radius),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveText(
                        label.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: labelColor,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 9),
                        Icon(icon, size: 16, color: labelColor),
                      ],
                    ],
                  ),
                ),
                if (overlay != null) Positioned.fill(child: overlay!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold gradient "Update now" CTA with a periodic shine sweep.
class _UpdateCta extends StatefulWidget {
  const _UpdateCta({required this.colors, required this.onTap});

  final AppColorsTheme colors;
  final VoidCallback onTap;

  @override
  State<_UpdateCta> createState() => _UpdateCtaState();
}

class _UpdateCtaState extends State<_UpdateCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return _PillButton(
      onTap: widget.onTap,
      label: 'update.update_now'.tr(),
      labelColor: colors.goldInk,
      icon: Icons.download_rounded,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.ctaTop, colors.ctaMid, colors.ctaBottom],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.ctaMid.withValues(alpha: 0.34),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      overlay: IgnorePointer(
        child: AnimatedBuilder(
          animation: _shine,
          builder: (context, _) {
            final w = MediaQuery.sizeOf(context).width;
            final x = -w * 0.6 + (_shine.value * w * 2.0);
            return Transform.translate(
              offset: Offset(x, 0),
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: w * 0.18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0),
                        AppColors.white.withValues(alpha: 0.50),
                        AppColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// "Required" note under the CTA for the blocking variant.
class _RequiredNote extends StatelessWidget {
  const _RequiredNote({required this.appName, required this.colors});

  final String appName;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, size: 11, color: colors.textTertiary),
        const SizedBox(width: 5),
        Flexible(
          child: ResponsiveText(
            'update.required_note',
            namedArgs: {'app': appName},
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Later" dismiss action for the optional variant. Outlined to read as the
/// secondary option next to the gold CTA; tapping it closes the dialog.
class _LaterButton extends StatelessWidget {
  const _LaterButton({required this.colors, required this.onTap});

  final AppColorsTheme colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      onTap: onTap,
      label: 'update.later'.tr(),
      labelColor: colors.textSecondary,
      decoration: BoxDecoration(
        color: colors.updateRecess,
        border: Border.all(color: colors.updateHairline),
      ),
    );
  }
}
