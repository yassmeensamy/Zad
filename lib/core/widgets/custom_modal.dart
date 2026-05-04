import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shared chrome for bottom-sheet modals across the app.
/// Renders the rounded ivory container, drag handle, title, optional
/// subtitle, and lifts above the keyboard.
///
/// Pass a translated [title] (and [subtitle]) widget — the modal does no
/// translation itself so callers stay free to use args, custom styling,
/// or `ResponsiveText`/`Text` interchangeably.
class CustomModal extends StatelessWidget {
  const CustomModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 14, 22, 28),
    this.contentSpacing = 16,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, -8),
              blurRadius: 24,
            ),
          ],
        ),
        padding: padding,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.oliveSoft.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              title,
              if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
              SizedBox(height: contentSpacing),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
