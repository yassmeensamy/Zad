import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Gold-gradient pill CTA shared by the Decree (create-success) and
/// Join Team screens. The trailing arrow auto-flips for RTL and is only
/// shown when the button is enabled (matches the Join screen's behaviour;
/// the Decree screen sets `enabled` true so the arrow always appears).
///
/// Entry animations are intentionally left to callers — wrap the widget
/// with `flutter_animate` if needed.
class GildedCta extends StatelessWidget {
  const GildedCta({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
    this.trailingIcon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.goldLight, colors.goldMid, colors.goldDeep],
                stops: const [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                top: BorderSide(color: Color(0x80FFFFFF)),
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: colors.goldMid.withValues(alpha: 0.32),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              height: 48,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(colors.goldInk),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.6,
                              color: colors.goldInk,
                            ),
                          ),
                          if (enabled) ...[
                            const SizedBox(width: 8),
                            Icon(
                              isRtl
                                  ? Icons.arrow_back_rounded
                                  : trailingIcon,
                              size: 14,
                              color: colors.goldInk,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
