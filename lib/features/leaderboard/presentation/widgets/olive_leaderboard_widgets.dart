import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// White-cream glass surface used by the Olive Light leaderboard summary
/// card. Soft top-down gradient with a thin olive border — matches the
/// `lb-olive-light .lb-glass` treatment from the design canvas.
class OliveGlassCard extends StatelessWidget {
  const OliveGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.oliveSoft.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveSoft.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
