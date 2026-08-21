import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../levels/data/models/level_model.dart';
import '../../../levels/presentation/screens/celebration.dart';
import '../../../../core/constants/quiz_points.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/sound_service.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    required this.points,
    required this.questionsCompleted,
    required this.totalRetries,
    required this.onDone,
    this.firstTryCorrect,
    this.elapsed,
    this.motivationalKey,
    this.level,
    this.perfectBonusAwarded = false,
  });

  final double points;

  final int questionsCompleted;

  final int totalRetries;

  final VoidCallback onDone;

  final int? firstTryCorrect;

  final Duration? elapsed;

  final String? motivationalKey;

  final LevelModel? level;

  final bool perfectBonusAwarded;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  @override
  void initState() {
    super.initState();
    // The level's reward sting, fired from initState so it plays once as the
    // screen lands rather than on every rebuild.
    unawaited(sl<SoundService>().playLevelComplete());
  }

  int get _correct {
    final c = widget.firstTryCorrect ??
        (widget.questionsCompleted - widget.totalRetries);
    return c.clamp(0, widget.questionsCompleted);
  }

  int get _accuracy {
    if (widget.questionsCompleted <= 0) return 0;
    return ((_correct / widget.questionsCompleted) * 100).round();
  }

  String _formatElapsed(Duration d) {
    final total = d.inSeconds;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final correct = _correct;
    final total = widget.questionsCompleted;
    final accuracy = _accuracy;
    final level = widget.level;

    final eyebrow = level != null
        ? 'quiz.result.level_complete'.tr(args: ['${level.order}'])
        : 'quiz.result.eyebrow'.tr();

    return LevelCompleteCelebration(
      eyebrow: eyebrow,
      title: 'quiz.result.title'.tr(),
      arabic: 'quiz.result.blessing'.tr(),
      subtitle: _Subtitle(
        correct: correct,
        total: total,
        closing: (widget.motivationalKey ?? 'quiz.result.closing').tr(),
        perfectBonusAwarded: widget.perfectBonusAwarded,
      ),
      stats: [
        CelebrationStat(
          value: '$correct',
          suffix: '/$total',
          label: 'quiz.result.stat_correct'.tr(),
        ),
        CelebrationStat(
          value: widget.elapsed != null
              ? _formatElapsed(widget.elapsed!)
              : '—',
          label: 'quiz.result.stat_time'.tr(),
        ),
        CelebrationStat(
          value: '$accuracy',
          suffix: '%',
          label: 'quiz.result.stat_accuracy'.tr(),
          fire: accuracy >= 100,
        ),
      ],
      xp: widget.points.round(),
      continueLabel: 'quiz.result.continue'.tr(),
      onContinue: widget.onDone,
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.correct,
    required this.total,
    required this.closing,
    required this.perfectBonusAwarded,
  });

  final int correct;
  final int total;
  final String closing;
  final bool perfectBonusAwarded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${'quiz.result.answered_prefix'.tr()} '),
          TextSpan(
            text: '$correct / $total',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          // The count is the first-try tally, so it's spelled out on the same
          // line rather than left to be read as a plain score.
          TextSpan(text: ' ${'quiz.result.first_try_suffix'.tr()}'),
          TextSpan(text: ' — $closing'),
        ],
      ),
      textAlign: TextAlign.center,
    );

    if (!perfectBonusAwarded) return line;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(height: 6),
        Text(
          'quiz.result.perfect_bonus'.tr(
            args: ['${QuizPoints.perfectRunBonus.round()}'],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
