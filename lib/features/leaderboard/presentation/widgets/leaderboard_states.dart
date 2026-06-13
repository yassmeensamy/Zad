import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Centered, italic hint used for empty podium / empty list states.
class LeaderboardEmptyHint extends StatelessWidget {
  const LeaderboardEmptyHint({
    super.key,
    required this.textKey,
    this.vertical = 0,
  });

  final String textKey;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Center(
        child: ResponsiveText(
          textKey.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
