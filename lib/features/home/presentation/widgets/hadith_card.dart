import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/hadith_model.dart';

/// "Hadith of the day" section: a titled header above a single hadith card.
/// Renders [hadith] from the home overview; while it is still loading the
/// caller wraps this in a [Skeletonizer] with a dash-filled placeholder so the
/// shapes below have the right size to mask.
class HadithCard extends StatelessWidget {
  const HadithCard({required this.hadith, super.key});

  final HadithModel hadith;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(),
        _CardBody(hadith: hadith),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
      child: ResponsiveText(
        'home.hadith.section_title',
        style: AppTextStyles.displaySmall.copyWith(
          fontSize: 22,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.hadith});

  final HadithModel hadith;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.olive.withValues(alpha: 0.10),
            colors.olive.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: colors.olive.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Collection name as the eyebrow, e.g. "SAḤĪḤ AL-BUKHĀRĪ".
          ResponsiveText(
            hadith.source.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.eyebrow(
              fontSize: 8.5,
              tracking: 0.26,
              color: colors.olive,
            ),
          ),
          const SizedBox(height: 7),
          ResponsiveText(
            hadith.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              height: 1.7,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          ResponsiveText(
            hadith.english,
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 11),
          _Attribution(hadith: hadith),
        ],
      ),
    );
  }
}

/// Footer line: narrator on the leading edge, hadith number on the trailing.
class _Attribution extends StatelessWidget {
  const _Attribution({required this.hadith});

  final HadithModel hadith;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final narrator = '${'home.hadith.narrator_prefix'.tr()}${hadith.narrator}';
    return Row(
      children: [
        Expanded(
          child: ResponsiveText(
            narrator,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.eyebrow(
              fontSize: 8.5,
              tracking: 0.2,
              color: colors.oliveSoft,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ResponsiveText(
          'home.hadith.hadith_no',
          args: [hadith.hadithNumber.toString()],
          maxLines: 1,
          style: AppTextStyles.eyebrow(
            fontSize: 8.5,
            tracking: 0.2,
            color: colors.oliveSoft,
          ),
        ),
      ],
    );
  }
}
