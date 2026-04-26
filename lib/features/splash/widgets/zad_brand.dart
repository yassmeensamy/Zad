import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        Text(
          'Zad',
          style: GoogleFonts.fraunces(
            fontSize: wordSize,
            fontWeight: FontWeight.w300,
            height: 1,
            color: colors.textArabic,
          ),
        ),
        SizedBox(height: gap),
        Text(
          'زاد',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            fontSize: arabicSize,
            color: colors.accentDeep,
          ),
        ),
        SizedBox(height: ruleGap),
        Container(width: ruleWidth, height: 1, color: colors.accent),
        SizedBox(height: tagGap),
        Text(
          tag.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: tagSize,
            fontWeight: FontWeight.w500,
            letterSpacing: tagSize * 0.42,
            color: dateSoft,
          ),
        ),
      ],
    );
  }
}
