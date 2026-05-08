import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/hadith_model.dart';

class HadithSectionHeader extends StatelessWidget {
  const HadithSectionHeader({super.key, this.onViewAllTap});

  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
      child: Text(
        'home.hadith.section_title'.tr(),
        style: AppTextStyles.displaySmall.copyWith(
          fontSize: 22,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class HadithCard extends StatelessWidget {
  const HadithCard({super.key, required this.hadith});

  final HadithModel hadith;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final lineStrong = colors.oliveDeep.withValues(alpha: 0.14);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border.all(color: lineStrong),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(text: hadith.source),
          const SizedBox(height: 14),
          Text(
            hadith.arabic,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyXLarge.copyWith(
              fontSize: 21,
              height: 1.7,
              color: colors.oliveDeep,
            ),
          ),
          const SizedBox(height: 14),
          Container(width: 32, height: 1, color: colors.accent),
          const SizedBox(height: 12),
          Text(
            hadith.english,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15.5,
              fontStyle: FontStyle.italic,
              height: 1.55,
              color: colors.oliveDeep,
            ),
          ),
          const SizedBox(height: 12),
          _NarratorLine(
            narrator: hadith.narrator,
            hadithNumber: hadith.hadithNumber,
          ),
        ],
      ),
    );
  }
}

class _NarratorLine extends StatelessWidget {
  const _NarratorLine({required this.narrator, required this.hadithNumber});

  final String narrator;
  final int hadithNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = AppTextStyles.bodySmall.copyWith(
      fontSize: 11,
      color: colors.dateSoft,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('home.hadith.narrator_prefix'.tr(), style: base),
        Text(
          narrator,
          style: base.copyWith(
            color: colors.olive,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(' · ', style: base),
        Text(
          'home.hadith.hadith_no'.tr(args: [hadithNumber.toString()]),
          style: base,
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 9.5 * 0.34,
            color: colors.textArabic,
          ),
        ),
      ],
    );
  }
}
