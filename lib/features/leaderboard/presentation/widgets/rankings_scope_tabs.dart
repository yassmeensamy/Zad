import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../cubit/rankings_state.dart';

/// Segmented control switching the leaderboard between Individuals and Teams.
class RankingsScopeTabs extends StatelessWidget {
  const RankingsScopeTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RankingsScope value;
  final ValueChanged<RankingsScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          for (final scope in RankingsScope.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(scope),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: scope == value
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.accent.withValues(alpha: 0.20),
                              colors.accentDeep.withValues(alpha: 0.12),
                            ],
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: ResponsiveText(
                    scope.labelKey.tr().toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: scope == value
                          ? colors.accent
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
