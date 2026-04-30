import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../widgets/responsive_text.dart';

/// Top-of-screen snackbar built on top of [Overlay].
class SnackBarHelper {
  SnackBarHelper._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static void showSuccess(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
    );
  }

  static void showError(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismiss();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => _TopSnackBar(
        message: message,
        icon: icon,
        iconColor: iconColor,
        onDismissed: _dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.onDismissed,
  });

  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onDismissed;

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final mq = MediaQuery.of(context);

    return Positioned(
      top: mq.padding.top + 8,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onDismissed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.oliveDeep,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.oliveDeep.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: widget.iconColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ResponsiveText(
                          widget.message.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.canvas,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
