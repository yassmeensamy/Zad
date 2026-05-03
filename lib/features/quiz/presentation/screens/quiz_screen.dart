import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../levels/data/models/level_model.dart';
import '../../data/models/choice_model.dart';
import '../../data/models/question_model.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import '../widgets/answer_choice_card.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/question_card.dart';
import '../widgets/quiz_action_bar.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/report_question_sheet.dart';
import '../widgets/result_view.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.levelId, this.level});

  final int levelId;
  final LevelModel? level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizCubit>(
      create: (_) => sl<QuizCubit>()..loadQuiz(levelId),
      child: _QuizView(levelId: levelId, level: level),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({required this.levelId, this.level});

  final int levelId;
  final LevelModel? level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state.isInitial || state.isLoading) {
            return _LoadingView(level: level);
          }
          if (state.isError) {
            return Column(
              children: [
                ZaadAppBar(
                  title: level?.title ?? 'quiz.eyebrow',
                  onBack: context.canPop() ? () => context.pop() : null,
                ),
                Expanded(
                  child: ErrorState(
                    message: state.errorMessage ?? 'errors.generic',
                    onRetry: () =>
                        context.read<QuizCubit>().loadQuiz(levelId),
                  ),
                ),
              ],
            );
          }
          if (state.isFinished) {
            return ResultView(
              points: state.points,
              questionsCompleted: state.totalQuestions,
              totalRetries: state.totalRetries,
              firstTryCorrect: state.firstTryCorrect,
              elapsed: state.elapsed,
              motivationalKey: state.motivationalMessageKey,
              onDone: () => _exit(context),
            );
          }
          return _ActiveView(level: level, state: state);
        },
      ),
    );
  }

  void _exit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({this.level});

  final LevelModel? level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final placeholderQuestion = QuestionModel(
      id: 0,
      text: '________________________________________',
      correctIndex: 1,
      explanation: null,
      source: null,
      choices: const [
        ChoiceModel(index: 1, text: '____________________'),
        ChoiceModel(index: 2, text: '____________________'),
        ChoiceModel(index: 3, text: '____________________'),
        ChoiceModel(index: 4, text: '____________________'),
      ],
    );

    return Column(
      children: [
        ZaadAppBar(
          title: level?.title ?? 'quiz.eyebrow',
          onBack: context.canPop() ? () => context.pop() : null,
        ),
        Expanded(
          child: Skeletonizer(
            effect: ShimmerEffect(
              baseColor: colors.olive.withValues(alpha: 0.10),
              highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                QuizProgressBar(total: 8, current: 1),
                const SizedBox(height: 22),
                QuestionCard(question: placeholderQuestion),
                const SizedBox(height: 18),
                for (final c in placeholderQuestion.choices)
                  AnswerChoiceCard(
                    choice: c,
                    label: 'A',
                    visualState: AnswerChoiceVisualState.idle,
                    onTap: null,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({
    required this.state,
    this.level,
  });

  final LevelModel? level;
  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<QuizCubit>();
    final isAnswered = state.isAnswered;
    final isLastInRound = state.currentIndex + 1 >= state.currentQueue.length;
    final hasMoreRounds = state.retryQueue.isNotEmpty;

    return Stack(
      children: [
        Column(
          children: [
            ZaadAppBar(
              title: level?.title ?? 'quiz.eyebrow',
              onBack: () => _confirmExit(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  QuizProgressBar(
                    total: state.roundLength,
                    current: state.positionInRound,
                  ),
                  const SizedBox(height: 22),
                  QuestionCard(question: question),
                  const SizedBox(height: 20),
                  for (var i = 0; i < question.choices.length; i++)
                    AnswerChoiceCard(
                      choice: question.choices[i],
                      label: _letterForIndex(i),
                      visualState: _visualStateFor(
                        choiceId: question.choices[i].index,
                        question: question,
                        state: state,
                      ),
                      onTap: isAnswered
                          ? null
                          : () =>
                              cubit.selectAnswer(question.choices[i].index),
                    ),
                  if (isAnswered) ...[
                    const SizedBox(height: 14),
                    FeedbackPanel(
                      isCorrect: state.isCorrect,
                      motivationalKey: state.motivationalMessageKey,
                      explanation: question.explanation,
                      reference: question.source,
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
            QuizActionBar(
              canAct: isAnswered,
              isSaved: state.isQuestionSaved(question.id),
              isLastInRound: isLastInRound,
              hasMoreRounds: hasMoreRounds,
              onSave: () => _onSave(context, cubit),
              onReport: () => _onReport(context),
              onNext: cubit.next,
            ),
          ],
        ),
        if (state.isAnswered)
          Positioned.fill(
            child: CelebrationOverlay(
              trigger: question.id + state.round * 1000,
              isCorrect: state.isCorrect,
              messageKey: state.motivationalMessageKey,
            ),
          ),
      ],
    );
  }

  AnswerChoiceVisualState _visualStateFor({
    required int choiceId,
    required QuestionModel question,
    required QuizState state,
  }) {
    final answered = state.isAnswered;
    final selected = state.selectedChoiceId == choiceId;
    final isCorrectChoice = question.correctIndex == choiceId;

    if (!answered) {
      return selected
          ? AnswerChoiceVisualState.selected
          : AnswerChoiceVisualState.idle;
    }

    if (isCorrectChoice) return AnswerChoiceVisualState.revealedCorrect;
    if (selected) return AnswerChoiceVisualState.revealedWrong;
    return AnswerChoiceVisualState.revealedMuted;
  }

  String _letterForIndex(int i) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    if (i >= 0 && i < letters.length) return letters[i];
    return '${i + 1}';
  }

  void _onSave(BuildContext context, QuizCubit cubit) {
    final wasSaved = state.isQuestionSaved(state.currentQuestion!.id);
    cubit.toggleSave();
    if (!wasSaved) {
      SnackBarHelper.showSuccess(
        context,
        message: 'quiz.actions.saved',
      );
    }
  }

  Future<void> _onReport(BuildContext context) async {
    final reasonKey = await ReportQuestionSheet.show(context);
    if (reasonKey == null) return;
    if (!context.mounted) return;
    SnackBarHelper.showSuccess(
      context,
      message: 'quiz.actions.report_sent',
    );
  }

  void _confirmExit(BuildContext context) {
    if (context.canPop()) context.pop();
  }
}
