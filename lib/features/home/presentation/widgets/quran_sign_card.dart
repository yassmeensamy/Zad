import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/quran_sign_model.dart';

/// "Quran sign of the day" section: a titled header above a single sign card.
/// Renders [sign] from the home overview; while it is still loading the caller
/// wraps this in a [Skeletonizer] with a dash-filled placeholder so the shapes
/// below have the right size to mask.
class QuranSignCard extends StatelessWidget {
  const QuranSignCard({required this.sign, super.key});

  final QuranSignModel sign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(),
        _CardBody(sign: sign),
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
        'home.quran_sign.section_title',
        style: AppTextStyles.displaySmall.copyWith(
          fontSize: 22,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.sign});

  final QuranSignModel sign;

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
          ResponsiveText(
            sign.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              height: 1.7,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 11),
          _Reference(sign: sign),
        ],
      ),
    );
  }
}

/// Footer line: the sign's reference number on the trailing edge.
class _Reference extends StatelessWidget {
  const _Reference({required this.sign});

  final QuranSignModel sign;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ResponsiveText(
          'home.quran_sign.reference_no',
          args: [sign.referenceNumber.toString()],
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
