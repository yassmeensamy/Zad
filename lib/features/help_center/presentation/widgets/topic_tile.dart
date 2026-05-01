import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/support_request_model.dart';

/// Tactile topic chip used in the 2x2 selection grid.
///
/// Idle state reads as a soft, low-contrast paper card. When [selected] flips
/// to true the card lifts: its accent color saturates the icon halo, an
/// indicator dot appears, and a soft outer glow forms. The transition is
/// driven by [AnimatedContainer] for a continuous, hand-drawn feel.
class TopicTile extends StatelessWidget {
  const TopicTile({
    super.key,
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final SupportTopicEnum topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = topic.accent(colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZaadRadii.card),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      accent.withValues(alpha: 0.14),
                      accent.withValues(alpha: 0.04),
                    ]
                  : [
                      colors.canvas.withValues(alpha: 0.95),
                      colors.canvasRaised.withValues(alpha: 0.78),
                    ],
            ),
            borderRadius: BorderRadius.circular(ZaadRadii.card),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.55)
                  : colors.olive.withValues(alpha: 0.14),
              width: selected ? 1.6 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colors.oliveDeep.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _IconHalo(icon: topic.icon, accent: accent, selected: selected),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: selected ? 1 : 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ResponsiveText(
                topic.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? accent : colors.oliveDeep,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: ResponsiveText(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconHalo extends StatelessWidget {
  const _IconHalo({
    required this.icon,
    required this.accent,
    required this.selected,
  });

  final IconData icon;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? [accent.withValues(alpha: 0.95), accent.withValues(alpha: 0.65)]
              : [
                  colors.canvas.withValues(alpha: 0.9),
                  colors.canvasRaised.withValues(alpha: 0.7),
                ],
        ),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0)
              : accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: selected ? colors.canvas : accent,
      ),
    );
  }
}
