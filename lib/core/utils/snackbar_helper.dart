import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../theme/theme.dart';
import '../constants/app_animations.dart';
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
      leading: const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 22,
      ),
    );
  }

  static void showError(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      leading: Lottie.asset(
        AppAnimations.error,
        width: 32,
        height: 32,
        repeat: false,
      ),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Widget leading,
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismiss();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => _TopSnackBar(
        message: message,
        leading: leading,
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
    required this.leading,
    required this.onDismissed,
  });

  final String message;
  final Widget leading;
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
                    borderRadius: BorderRadius.circular(ZaadRadii.lg),
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
                      widget.leading,
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
      );
  }
}
