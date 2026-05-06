import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../drafts/presentation/cubit/drafts_cubit.dart';
import '../../../drafts/presentation/cubit/drafts_state.dart';
import '../../../drafts/presentation/widgets/draft_note_sheet.dart';
import '../../../levels/data/models/level_model.dart';
import '../../data/models/choice_model.dart';
import '../../data/models/question_model.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_history_cubit.dart';
import '../cubit/quiz_history_state.dart';
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
    final isReview = level?.isCompleted ?? false;
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuizCubit>(create: (_) => sl<QuizCubit>()),
        BlocProvider<QuizHistoryCubit>(create: (_) => QuizHistoryCubit()),
        BlocProvider<DraftsCubit>(create: (_) => sl<DraftsCubit>()),
      ],
      child: BlocListener<QuizCubit, QuizState>(
        listenWhen: (prev, curr) =>
            prev.history.isNotEmpty && curr.history.isEmpty,
        listener: (context, _) => context.read<QuizHistoryCubit>().exit(),
        child: _QuizBootstrap(
          levelId: levelId,
          review: isReview,
          child: _QuizView(levelId: levelId, level: level),
        ),
      ),
    );
  }
}

/// Loads the quiz, then loads the user's drafts when at least one question
/// is already drafted server-side. The drafts list is read directly off
/// [DraftsCubit] from the screen — no manual sync into [QuizCubit].
class _QuizBootstrap extends StatefulWidget {
  const _QuizBootstrap({
    required this.levelId,
    required this.child,
    this.review = false,
  });

  final int levelId;
  final bool review;
  final Widget child;

  @override
  State<_QuizBootstrap> createState() => _QuizBootstrapState();
}

class _QuizBootstrapState extends State<_QuizBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final quizCubit = context.read<QuizCubit>();
    await quizCubit.loadQuiz(widget.levelId, review: widget.review);
    if (!mounted) return;

    if (quizCubit.state.allQuestions.any((q) => q.isDrafted)) {
      await context.read<DraftsCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
            if (state.isReview) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) _exit(context);
              });
              return _LoadingView(level: level);
            }
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
    return BlocBuilder<QuizHistoryCubit, QuizHistoryState>(
      builder: (context, historyState) => _buildContent(context, historyState),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuizHistoryState historyState,
  ) {
    final viewingEntry = _viewingEntry(historyState);
    final question = viewingEntry?.question ?? state.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    final quizCubit = context.read<QuizCubit>();
    final historyCubit = context.read<QuizHistoryCubit>();
    final isReview = state.isReview;
    final isViewingHistory = historyState.isViewing;
    final isAnswered = isViewingHistory || state.isAnswered;
    final showFeedback = isReview || isAnswered;
    final canTapAnswer = !isReview && !isViewingHistory && !state.isAnswered;
    final selectedChoiceId =
        viewingEntry?.choiceId ?? state.selectedChoiceId;
    final isLastInRound = !isViewingHistory &&
        state.currentIndex + 1 >= state.currentQueue.length;
    final hasMoreRounds = !isReview && state.retryQueue.isNotEmpty;
    final canGoPrevious = _canGoPrevious(historyState);

    void onPrevious() {
      if (isReview) {
        quizCubit.reviewBack();
      } else {
        historyCubit.back(
          historyLength: state.history.length,
          liveIsAnswered: state.isAnswered,
        );
      }
    }

    void onNext() {
      if (isViewingHistory) {
        historyCubit.forward(state.history.length);
      } else {
        quizCubit.next();
      }
    }

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
                  _PreviousQuestionButton(
                    onTap: canGoPrevious ? onPrevious : null,
                  ),
                  const SizedBox(height: 6),
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
                      label: AnswerChoiceCard.labelForIndex(i),
                      visualState: _visualStateFor(
                        choiceId: question.choices[i].index,
                        question: question,
                        isAnswered: isAnswered,
                        selectedChoiceId: selectedChoiceId,
                      ),
                      onTap: canTapAnswer
                          ? () => quizCubit.selectAnswer(
                                question.choices[i].index,
                              )
                          : null,
                    ),
                  if (showFeedback) ...[
                    const SizedBox(height: 14),
                    FeedbackPanel(
                      isCorrect: isReview
                          ? true
                          : isViewingHistory
                              ? viewingEntry!.isCorrect
                              : state.isCorrect,
                      motivationalKey: (isReview || isViewingHistory)
                          ? null
                          : state.motivationalMessageKey,
                      explanation: question.explanation,
                      reference: question.source,
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
            BlocBuilder<DraftsCubit, DraftsState>(
              buildWhen: (prev, curr) =>
                  prev.drafts != curr.drafts ||
                  prev.crudStatus != curr.crudStatus,
              builder: (context, draftsState) => QuizActionBar(
                canAct: showFeedback,
                isSaved:
                    draftsState.findByQuestionId(question.id) != null,
                isLastInRound: isLastInRound,
                hasMoreRounds: hasMoreRounds,
                onSave: () => _onSave(context, question.id),
                onReport: () => _onReport(context),
                onNext: onNext,
              ),
            ),
          ],
        ),
        if (!isReview && !isViewingHistory && state.isAnswered)
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

  QuizHistoryEntry? _viewingEntry(QuizHistoryState historyState) {
    final i = historyState.viewingIndex;
    if (i == null || i < 0 || i >= state.history.length) return null;
    return state.history[i];
  }

  bool _canGoPrevious(QuizHistoryState historyState) {
    if (state.isReview) return state.currentIndex > 0;
    final i = historyState.viewingIndex;
    if (i != null) return i > 0;
    final livePos =
        state.isAnswered ? state.history.length - 1 : state.history.length;
    return livePos > 0;
  }

  AnswerChoiceVisualState _visualStateFor({
    required int choiceId,
    required QuestionModel question,
    required bool isAnswered,
    required int? selectedChoiceId,
  }) {
    final isCorrectChoice = question.correctIndex == choiceId;

    if (state.isReview) {
      return isCorrectChoice
          ? AnswerChoiceVisualState.revealedCorrect
          : AnswerChoiceVisualState.revealedMuted;
    }

    final selected = selectedChoiceId == choiceId;

    if (!isAnswered) {
      return selected
          ? AnswerChoiceVisualState.selected
          : AnswerChoiceVisualState.idle;
    }

    if (isCorrectChoice) return AnswerChoiceVisualState.revealedCorrect;
    if (selected) return AnswerChoiceVisualState.revealedWrong;
    return AnswerChoiceVisualState.revealedMuted;
  }


  Future<void> _onSave(BuildContext context, int questionId) async {
    final draftsCubit = context.read<DraftsCubit>();
    if (draftsCubit.state.isCrudLoading) return;

    final existing = draftsCubit.state.findByQuestionId(questionId);
    if (existing != null) {
      await draftsCubit.delete(existing.id);
      return;
    }

    final ok = await DraftNoteSheet.show(
      context,
      onSubmit: (note) async {
        await draftsCubit.create(questionId: questionId, note: note);
        return draftsCubit.state.findByQuestionId(questionId) != null;
      },
    );
    if (ok && context.mounted) {
      SnackBarHelper.showSuccess(context, message: 'quiz.actions.saved');
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

class _PreviousQuestionButton extends StatelessWidget {
  const _PreviousQuestionButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final disabled = onTap == null;
    final fg = disabled ? colors.textPlaceholder : colors.oliveDeep;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ZaadRadii.smAll,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(
                  'quiz.actions.previous'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
