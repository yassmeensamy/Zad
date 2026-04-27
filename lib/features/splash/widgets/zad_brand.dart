import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/responsive_text.dart';
import '../../../theme/theme.dart';

/// Wordmark "Zad" + Arabic "زاد" + amber rule + uppercase tagline.
class ZadBrand extends StatelessWidget {
  const ZadBrand({
    super.key,
    this.wordSize = 78,
    this.arabicSize = 34,
    this.tagSize = 11,
    this.ruleWidth = 36,
    this.gap = 14,
    this.ruleGap = 24,
    this.tagGap = 18,
    this.dateSoft = const Color(0xFF8D5C36),
    this.tag = 'Your daily companion',
  });

  /// Compact preset used on auth screens (login). Matches the Olive v2 design:
  /// 44px wordmark, 18px Arabic, 9.5px tag, 28px rule.
  const ZadBrand.compact({
    super.key,
    this.dateSoft = const Color(0xFF8D5C36),
    this.tag = 'Your daily companion',
  })  : wordSize = 44,
        arabicSize = 18,
        tagSize = 9.5,
        ruleWidth = 28,
        gap = 6,
        ruleGap = 12,
        tagGap = 12;

  final double wordSize;
  final double arabicSize;
  final double tagSize;
  final double ruleWidth;
  final double gap;
  final double ruleGap;
  final double tagGap;
  final Color dateSoft;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveText(
          'Zad',
          style: GoogleFonts.fraunces(
            fontSize: wordSize,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.5,
            color: colors.oliveDeep,
          ),
        ),
        SizedBox(height: gap),
        ResponsiveText(
          'زاد',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            fontSize: arabicSize,
            color: colors.textArabic,
          ),
        ),
        SizedBox(height: ruleGap),
        Container(width: ruleWidth, height: 1, color: colors.accent),
        SizedBox(height: tagGap),
        ResponsiveText(
          tag.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: tagSize,
            fontWeight: FontWeight.w600,
            letterSpacing: tagSize * 0.42,
            color: colors.oliveSoft,
          ),
        ),
      ],
    );
  }
}
