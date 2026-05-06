import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

enum BubbleSide { left, right }

class ConversationBubble extends StatelessWidget {
  const ConversationBubble({
    super.key,
    required this.authorLabel,
    required this.body,
    required this.accent,
    required this.icon,
    this.side = BubbleSide.left,
    this.createdAt,
  });

  final String authorLabel;
  final String body;
  final Color accent;
  final IconData icon;
  final BubbleSide side;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final relative = formatRelative(context, createdAt);
    final isRight = side == BubbleSide.right;

    final bubble = Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isRight ? 16 : 4),
            topRight: Radius.circular(isRight ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: Border.all(color: accent.withValues(alpha: 0.22), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              authorLabel,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                height: 1.5,
                color: colors.textPrimary,
              ),
            ),
            if (relative != null) ...[
              const SizedBox(height: 8),
              ResponsiveText(
                relative,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 10.5,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final avatar = _Avatar(icon: icon, accent: accent);
    const gap = SizedBox(width: 10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isRight ? [bubble, gap, avatar] : [avatar, gap, bubble],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.14),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: accent.withValues(alpha: 0.9)),
    );
  }
}
