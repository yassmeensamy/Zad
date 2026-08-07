import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'responsive_text.dart';

/// Tone applied to a scoring row's value pill.
enum _ScoreTone { gain, loss, bonus }

/// Explains how points are earned — the daily check-in point, the speed tiers
/// for a first-try answer, retry credit, the wrong-answer penalty, and the
/// perfect-level bonus.
///
/// Opened from the lamp button in the levels app bar via [show].
class PointsGuideSheet extends StatelessWidget {
  const PointsGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
      builder: (_) => const PointsGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ZaadRadii.dialog),
        ),
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: ZaadRadii.pillAll,
              ),
            ),
            const SizedBox(height: 18),
            ResponsiveText(
              'points_guide.title',
              textAlign: TextAlign.center,
              style: ZaadType.titleAccent.copyWith(
                fontSize: 20,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 10),
            Container(width: 28, height: 1, color: colors.accent),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    _ShowingUpCard(),
                    SizedBox(height: 12),
                    _AnswerCard(),
                    SizedBox(height: 12),
                    _BonusBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "just for showing up" card — the daily check-in point.
class _ShowingUpCard extends StatelessWidget {
  const _ShowingUpCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return _GuideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Glyph('🌙'),
              const SizedBox(width: 10),
              Expanded(
                child: ResponsiveText(
                  'points_guide.showing_up_title',
                  style: ZaadType.sectionLabel.copyWith(
                    color: colors.oliveDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            'points_guide.showing_up_body',
            style: ZaadType.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The "when you answer" card — speed tiers, retries, and the penalty.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return _GuideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'points_guide.answer_title',
            style: ZaadType.sectionLabel.copyWith(color: colors.oliveDeep),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Glyph('⚡'),
              const SizedBox(width: 10),
              Expanded(
                child: ResponsiveText(
                  'points_guide.first_try',
                  style: ZaadType.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _ScoreRow(
            labelKey: 'points_guide.under_10',
            valueKey: 'points_guide.under_10_value',
            indented: true,
          ),
          const _ScoreRow(
            labelKey: 'points_guide.under_20',
            valueKey: 'points_guide.under_20_value',
            indented: true,
          ),
          const _ScoreRow(
            labelKey: 'points_guide.after_that',
            valueKey: 'points_guide.after_that_value',
            indented: true,
          ),
          const _CardDivider(),
          const _ScoreRow(
            glyph: '🔁',
            labelKey: 'points_guide.second_try',
            valueKey: 'points_guide.second_try_value',
          ),
          const _ScoreRow(
            labelKey: 'points_guide.third_try',
            valueKey: 'points_guide.third_try_value',
            indented: true,
          ),
          const _CardDivider(),
          const _ScoreRow(
            glyph: '❌',
            labelKey: 'points_guide.wrong',
            valueKey: 'points_guide.wrong_value',
            tone: _ScoreTone.loss,
          ),
        ],
      ),
    );
  }
}

/// The perfect-level bonus, lifted out of the card onto a gold banner.
class _BonusBanner extends StatelessWidget {
  const _BonusBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: ZaadRadii.xlAll,
        border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Glyph('🏆'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'points_guide.perfect',
                  style: ZaadType.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _ValuePill(
                  valueKey: 'points_guide.perfect_value',
                  tone: _ScoreTone.bonus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One "label → value" scoring line. [indented] aligns the label under the
/// glyph column of the rule it belongs to.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.labelKey,
    required this.valueKey,
    this.glyph,
    this.indented = false,
    this.tone = _ScoreTone.gain,
  });

  final String labelKey;
  final String valueKey;
  final String? glyph;
  final bool indented;
  final _ScoreTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (glyph != null) ...[
            _Glyph(glyph!),
            const SizedBox(width: 10),
          ] else
            SizedBox(width: indented ? 30 : 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: ResponsiveText(
                labelKey,
                style: ZaadType.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ValuePill(valueKey: valueKey, tone: tone),
        ],
      ),
    );
  }
}

/// The trailing pill carrying the point value for a [_ScoreRow].
class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.valueKey, required this.tone});

  final String valueKey;
  final _ScoreTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final Color ink;
    switch (tone) {
      case _ScoreTone.loss:
        ink = context.colorScheme.error;
      case _ScoreTone.bonus:
        ink = colors.accentDeep;
      case _ScoreTone.gain:
        ink = colors.oliveLeaf;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.12),
        borderRadius: ZaadRadii.pillAll,
        border: Border.all(color: ink.withValues(alpha: 0.32)),
      ),
      child: ResponsiveText(
        valueKey,
        textAlign: TextAlign.center,
        style: ZaadType.bodySmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    );
  }
}

/// Rounded surface shared by the guide's cards.
class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: ZaadRadii.xlAll,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: context.appColors.borderSubtle),
    );
  }
}

/// Fixed-width emoji slot so every rule's text starts on the same column.
class _Glyph extends StatelessWidget {
  const _Glyph(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Text(
        emoji,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, height: 1.3),
      ),
    );
  }
}
