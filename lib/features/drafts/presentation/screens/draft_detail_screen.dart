import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../quiz/presentation/widgets/answer_choice_card.dart';
import '../../../quiz/presentation/widgets/feedback_panel.dart';
import '../../../quiz/presentation/widgets/question_card.dart';
import '../../data/models/draft_model.dart';
import '../cubit/drafts_cubit.dart';
import '../cubit/drafts_state.dart';
import '../widgets/draft_note_sheet.dart';

class DraftDetailScreen extends StatelessWidget {
  const DraftDetailScreen({super.key, required this.draft});
  final DraftModel draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<DraftsCubit, DraftsState>(
      listenWhen: (a, b) => a.crudStatus != b.crudStatus,
      listener: (context, state) {
        switch (state.crudStatus) {
          case CrudStatus.deleted:
            if (context.canPop()) context.pop();
          case CrudStatus.updated:
            SnackBarHelper.showSuccess(
              context,
              message: 'drafts.note_saved',
            );
          case CrudStatus.error:
            SnackBarHelper.showError(
              context,
              message: state.crudErrorMessage ?? 'errors.generic',
            );
          case CrudStatus.idle:
          case CrudStatus.loading:
          case CrudStatus.created:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: ZaadAppBar(
          title: 'drafts.title',
          onBack: context.canPop() ? () => context.pop() : null,
        ),
        body: _DraftDetailBody(draft: draft),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: _DeleteButton(draftId: draft.id),
          ),
        ),
      ),
    );
  }
}

class _DraftDetailBody extends StatelessWidget {
  const _DraftDetailBody({required this.draft});

  final DraftModel draft;

  @override
  Widget build(BuildContext context) {
    final question = draft.question;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: QuestionCard(question: question),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: question.choices.length,
            itemBuilder: (_, i) => AnswerChoiceCard(
              choice: question.choices[i],
              label: AnswerChoiceCard.labelForIndex(i),
              visualState:
                  question.choices[i].index == question.correctIndex
                      ? AnswerChoiceVisualState.revealedCorrect
                      : AnswerChoiceVisualState.revealedMuted,
              onTap: null,
            ),
          ),
        ),
        if (question.hasFeedback) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: FeedbackPanel(
                isCorrect: true,
                explanation: question.explanation,
                reference: question.source,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverToBoxAdapter(child: _NoteSection(draft: draft)),
        ),
      ],
    );
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.draft});

  final DraftModel draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final note = draft.note;
    final hasNote = note != null && note.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.canvasRaised.withValues(alpha: 0.6),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 16,
                color: colors.accentDeep,
              ),
              const SizedBox(width: 8),
              ResponsiveText(
                'drafts.your_note',
                style: ZaadType.eyebrowSm.copyWith(color: colors.accentDeep),
              ),
              const Spacer(),
              if (hasNote)
                TextButton(
                  onPressed: () => _removeNote(context),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: ResponsiveText(
                    'drafts.remove_note',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ResponsiveText(
            hasNote ? note : 'drafts.no_note',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              height: 1.55,
              fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
              color: hasNote ? colors.textSecondary : colors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _editNote(context),
              icon: Icon(
                hasNote ? Icons.edit_outlined : Icons.add_rounded,
                size: 16,
                color: colors.oliveDeep,
              ),
              label: ResponsiveText(
                hasNote ? 'drafts.edit_note' : 'drafts.note_label',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.oliveDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    final cubit = context.read<DraftsCubit>();
    await DraftNoteSheet.show(
      context,
      initialNote: draft.note,
      onSubmit: (note) async {
        if (note == draft.note) return true;
        await cubit.updateNote(id: draft.id, note: note);
        return cubit.state.crudStatus == CrudStatus.updated;
      },
    );
  }

  Future<void> _removeNote(BuildContext context) async {
    await context.read<DraftsCubit>().updateNote(id: draft.id, note: null);
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.draftId});

  final int draftId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    return CustomButton.full(
      onTap: () => context.read<DraftsCubit>().delete(draftId),
      theme: CustomButtonTheme(
        height: 52,
        borderRadius: 16,
        backgroundColor: colors.canvas.withValues(alpha: 0.6),
        borderColor: errorColor.withValues(alpha: 0.28),
        textColor: errorColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, size: 18, color: errorColor),
          const SizedBox(width: 10),
          ResponsiveText(
            'drafts.delete_confirm_cta',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
