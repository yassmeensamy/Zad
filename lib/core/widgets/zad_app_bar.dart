import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// A premium, restrained app bar used across the app.
///
/// - Soft pill-shaped leading button that reads as a tactile chip.
/// - Centered title in Cairo with an optional small caption beneath it.
/// - Warm canvas fill with a soft, low-spread shadow that lifts the bar
///   off the body without a harsh divider.
class ZadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZadAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  /// Localization key for the title.
  final String title;

  /// Optional localization key shown as a small caption under the title.
  final String? subtitle;

  /// If null, the leading button is hidden (e.g. root tabs).
  final VoidCallback? onBack;

  final List<Widget> actions;

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.canvas,
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: onBack == null
                      ? null
                      : _PillIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: onBack!,
                          color: colors.oliveDeep,
                          background: colors.olive.withValues(alpha: 0.06),
                          border: colors.olive.withValues(alpha: 0.16),
                        ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ResponsiveText(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colors.oliveDeep,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        ResponsiveText(
                          subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: actions.isEmpty
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
