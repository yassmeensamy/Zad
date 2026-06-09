import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../levels/data/models/level_model.dart';
import '../../../levels/presentation/screens/celebration.dart';

/// Quiz result — the **Level Complete** celebration, driven entirely by the
/// finished [QuizState] values forwarded from `QuizScreen`. No mock data: the
/// eyebrow, stats, accuracy and XP are all derived from the real attempt.
class ResultView extends StatelessWidget {
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
  });

  /// XP earned this attempt.
  final int points;

  /// Total questions in the level.
  final int questionsCompleted;

  /// Number of retries across the attempt.
  final int totalRetries;

  /// Primary action — leaves the result.
  final VoidCallback onDone;

  /// Questions answered correctly on the first try. Falls back to
  /// `questionsCompleted - totalRetries` when not provided.
  final int? firstTryCorrect;

  /// Total attempt time. Hidden (shown as `—`) when null.
  final Duration? elapsed;

  /// Localisation key for the closing line under the title.
  final String? motivationalKey;

  /// The completed level — drives the eyebrow ("Level N · Complete").
  final LevelModel? level;

  int get _correct {
    final c = firstTryCorrect ?? (questionsCompleted - totalRetries);
    return c.clamp(0, questionsCompleted);
  }

  int get _accuracy {
    if (questionsCompleted <= 0) return 0;
    return ((_correct / questionsCompleted) * 100).round();
  }

  String _formatElapsed(Duration d) {
    final total = d.inSeconds;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final correct = _correct;
    final total = questionsCompleted;
    final accuracy = _accuracy;

    final eyebrow = level != null
        ? 'quiz.result.level_complete'.tr(args: ['${level!.order}'])
        : 'quiz.result.eyebrow'.tr();

    return LevelCompleteCelebration(
      eyebrow: eyebrow,
      title: 'quiz.result.title'.tr(),
      arabic: 'quiz.result.blessing'.tr(),
      subtitle: _Subtitle(
        correct: correct,
        total: total,
        closing: (motivationalKey ?? 'quiz.result.closing').tr(),
      ),
      stats: [
        CelebrationStat(
          value: '$correct',
          suffix: '/$total',
          label: 'quiz.result.stat_correct'.tr(),
        ),
        CelebrationStat(
          value: elapsed != null ? _formatElapsed(elapsed!) : '—',
          label: 'quiz.result.stat_time'.tr(),
        ),
        CelebrationStat(
          value: '$accuracy',
          suffix: '%',
          label: 'quiz.result.stat_accuracy'.tr(),
          fire: accuracy >= 100,
        ),
      ],
      xp: points,
      continueLabel: 'quiz.result.continue'.tr(),
      onContinue: onDone,
    );
  }
}

/// The supporting line: "You answered **C / T** — closing". The score is
/// emphasised in bright ivory against the muted subtitle ink.
class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.correct,
    required this.total,
    required this.closing,
  });

  final int correct;
  final int total;
  final String closing;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${'quiz.result.answered_prefix'.tr()} '),
          TextSpan(
            text: '$correct / $total',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' — $closing'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
