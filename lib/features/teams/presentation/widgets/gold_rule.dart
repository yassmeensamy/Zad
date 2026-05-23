import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// 1-px gradient hairline that fades from transparent → `goldDeep` (or the
/// reverse). Used by the ornament eyebrows, "or" dividers and section
/// breaks throughout the Teams flow.
class GoldRule extends StatelessWidget {
  const GoldRule({
    super.key,
    required this.reversed,
    this.width = 30,
    this.height = 1,
  });

  final bool reversed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    final colors = reversed
        ? [goldDeep, goldDeep.withValues(alpha: 0)]
        : [goldDeep.withValues(alpha: 0), goldDeep];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
    );
  }
}

/// `gold-rule · dot · gold-rule` ornament — a small horizontal section
/// break used between Join (D3) recovery copy and the Decree copy block.
class DotRule extends StatelessWidget {
  const DotRule({
    super.key,
    this.ruleWidth = 30,
    this.dotSize = 5,
    this.spacing = 8,
  });

  final double ruleWidth;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoldRule(reversed: false, width: ruleWidth),
        SizedBox(width: spacing),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: goldDeep,
          ),
        ),
        SizedBox(width: spacing),
        GoldRule(reversed: true, width: ruleWidth),
      ],
    );
  }
}
