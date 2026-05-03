import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Slim segmented progress dots showing position within the current round.
/// Shows no round number, no point counter — keeps the screen calm.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    super.key,
    required this.total,
    required this.current,
  });

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (total <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              height: 4,
              decoration: BoxDecoration(
                color: i < current
                    ? colors.olive
                    : colors.olive.withValues(alpha: 0.14),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
