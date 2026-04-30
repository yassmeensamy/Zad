import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Reusable error-state placeholder. Shows an icon, a message, and an
/// optional retry button when [onRetry] is provided.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryLabelKey = 'retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String retryLabelKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: colors.warning),
            const SizedBox(height: 10),
            ResponsiveText(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textArabic,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.olive),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: ResponsiveText(
                  retryLabelKey,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.oliveDeep,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
