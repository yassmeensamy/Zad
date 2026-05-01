import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Reusable empty-state placeholder. Renders a circular olive medallion
/// with an [icon], a title, and an optional subtitle/hint.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.oliveLeaf.withValues(alpha: 0.20),
                    colors.olive.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(
                  color: colors.olive.withValues(alpha: 0.22),
                  width: 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 44, color: colors.oliveDeep),
            ),
            const SizedBox(height: 18),
            ResponsiveText(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.oliveDeep,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              ResponsiveText(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 13,
                  color: colors.olive.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
