import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/textforms/main_text_form.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../data/models/support_request_model.dart';
import '../cubit/help_center_cubit.dart';
import '../cubit/help_center_state.dart';
import '../widgets/help_success_card.dart';
import '../widgets/topic_tile.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HelpCenterCubit>(
      create: (_) => sl<HelpCenterCubit>(),
      child: const _HelpCenterView(),
    );
  }
}

class _HelpCenterView extends StatefulWidget {
  const _HelpCenterView();

  @override
  State<_HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<_HelpCenterView> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _resetControllers() {
    _subjectController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZaadAppBar(
        title: 'help_center.title',
        subtitle: 'help_center.subtitle',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: BlocListener<HelpCenterCubit, HelpCenterState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.isSent) {
            FocusScope.of(context).unfocus();
            _resetControllers();
          } else if (state.isError) {
            SnackBarHelper.showError(
              context,
              message: state.errorMessage ?? 'help_center.send_failed',
            );
            context.read<HelpCenterCubit>().dismissError();
          }
        },
        child: Stack(
          children: [
            const _BackdropOrnament(),
            BlocBuilder<HelpCenterCubit, HelpCenterState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: state.isSent && state.lastSent != null
                      ? _SuccessLayer(
                          key: const ValueKey('success'),
                          request: state.lastSent!,
                          onSendAnother: () {
                            _resetControllers();
                            context.read<HelpCenterCubit>().resetForm();
                          },
                          onClose: () {
                            if (context.canPop()) context.pop();
                          },
                        )
                      : _ComposerLayer(
                          key: const ValueKey('composer'),
                          subjectController: _subjectController,
                          messageController: _messageController,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackdropOrnament extends StatelessWidget {
  const _BackdropOrnament();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -80,
              right: -80,
              height: 320,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.0,
                    colors: [
                      colors.oliveLeaf.withValues(alpha: 0.18),
                      colors.olive.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -100,
              width: 260,
              height: 260,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accent.withValues(alpha: 0.10),
                      colors.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessLayer extends StatelessWidget {
  const _SuccessLayer({
    super.key,
    required this.request,
    required this.onSendAnother,
    required this.onClose,
  });

  final SupportRequestModel request;
  final VoidCallback onSendAnother;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        HelpSuccessCard(
          request: request,
          onSendAnother: onSendAnother,
          onClose: onClose,
        ),
      ],
    );
  }
}

class _ComposerLayer extends StatelessWidget {
  const _ComposerLayer({
    super.key,
    required this.subjectController,
    required this.messageController,
  });

  final TextEditingController subjectController;
  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        const _Greeting(),
        const SizedBox(height: 32),
        const _SectionLabel(textKey: 'help_center.choose_topic'),
        const SizedBox(height: 16),
        const _TopicGrid(),
        const SizedBox(height: 32),
        BlocBuilder<HelpCenterCubit, HelpCenterState>(
          buildWhen: (a, b) => a.topic != b.topic,
          builder: (context, state) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                child: state.topic == null
                    ? const _PromptHint(key: ValueKey('prompt'))
                    : _ComposerCard(
                        key: const ValueKey('composer-card'),
                        subjectController: subjectController,
                        messageController: messageController,
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: colors.textTertiary,
              ),
              const SizedBox(width: 6),
              ResponsiveText(
                'help_center.reply_window',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.olive.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: 8),
              ResponsiveText(
                'help_center.eyebrow',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.oliveDeep,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ResponsiveText(
          'help_center.heading',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 10),
        ResponsiveText(
          'help_center.lede',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.textKey});
  final String textKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.oliveLeaf, colors.oliveDeep],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          ResponsiveText(
            textKey,
            style: ZaadType.sectionLabel.copyWith(color: colors.oliveDeep),
          ),
        ],
      ),
    );
  }
}

class _TopicGrid extends StatelessWidget {
  const _TopicGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      buildWhen: (a, b) => a.topic != b.topic,
      builder: (context, state) {
        final cubit = context.read<HelpCenterCubit>();
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            for (final topic in SupportTopicEnum.values)
              TopicTile(
                topic: topic,
                selected: state.topic == topic,
                onTap: () => cubit.selectTopic(topic),
              ),
          ],
        );
      },
    );
  }
}

class _PromptHint extends StatelessWidget {
  const _PromptHint({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: colors.canvasRaised.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ZaadRadii.xl),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.10),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 18,
            color: colors.oliveLeaf,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ResponsiveText(
              'help_center.pick_topic_hint',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    super.key,
    required this.subjectController,
    required this.messageController,
  });

  final TextEditingController subjectController;
  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvas.withValues(alpha: 0.96),
            colors.canvasRaised.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(ZaadRadii.xxl),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SelectedTopicChip(),
          const SizedBox(height: 22),
          _FieldLabel(textKey: 'help_center.subject_label'),
          const SizedBox(height: 10),
          MainTextFormField(
            controller: subjectController,
            hintText: 'help_center.subject_hint'.tr(),
            textCapitalization: TextCapitalization.sentences,
            onChanged: context.read<HelpCenterCubit>().updateSubject,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.oliveDeep,
            ),
            hintStyle: TextStyle(
              fontSize: 13,
              color: colors.textPlaceholder,
            ),
            borderRadius: BorderRadius.circular(ZaadRadii.md),
          ),
          const SizedBox(height: 22),
          _FieldLabel(textKey: 'help_center.message_label'),
          const SizedBox(height: 10),
          MainTextFormField(
            controller: messageController,
            hintText: 'help_center.message_hint'.tr(),
            textCapitalization: TextCapitalization.sentences,
            minLines: 4,
            maxLines: 8,
            maxLength: 1000,
            onChanged: context.read<HelpCenterCubit>().updateMessage,
          ),
          const SizedBox(height: 12),
          const _CharacterFloor(),
          const SizedBox(height: 24),
          const _SendButton(),
        ],
      ),
    );
  }
}

class _SelectedTopicChip extends StatelessWidget {
  const _SelectedTopicChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      buildWhen: (a, b) => a.topic != b.topic,
      builder: (context, state) {
        final topic = state.topic;
        if (topic == null) return const SizedBox.shrink();
        final accent = topic.accent(colors);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: accent.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(topic.icon, size: 14, color: accent),
              const SizedBox(width: 8),
              ResponsiveText(
                topic.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.textKey});
  final String textKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ResponsiveText(
      textKey,
      style: ZaadType.sectionLabel.copyWith(
        fontSize: 11,
        letterSpacing: 0.7,
        color: colors.textSecondary,
      ),
    );
  }
}

class _CharacterFloor extends StatelessWidget {
  const _CharacterFloor();

  static const int _minChars = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      buildWhen: (a, b) => a.message.length != b.message.length,
      builder: (context, state) {
        final length = state.message.trim().length;
        final reached = length >= _minChars;
        final remaining = (_minChars - length).clamp(0, _minChars);
        return Row(
          children: [
            Icon(
              reached
                  ? Icons.check_circle_rounded
                  : Icons.edit_note_rounded,
              size: 14,
              color: reached ? colors.success : colors.textTertiary,
            ),
            const SizedBox(width: 6),
            ResponsiveText(
              reached
                  ? 'help_center.ready_to_send'
                  : 'help_center.char_floor',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: reached ? colors.success : colors.textTertiary,
              ),
            ),
            if (!reached) ...[
              const SizedBox(width: 4),
              Text(
                '($remaining)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      buildWhen: (a, b) =>
          a.canSubmit != b.canSubmit || a.status != b.status,
      builder: (context, state) {
        final accent =
            state.topic?.accent(colors) ?? colors.olive;
        final enabled = state.canSubmit;
        return CustomButton.full(
          enabled: enabled,
          loading: state.isSending,
          onTap: () => context.read<HelpCenterCubit>().submit(),
          theme: CustomButtonTheme(
            height: 54,
            backgroundColor: accent,
            textColor: colors.canvas,
            borderRadius: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.isSending)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.canvas,
                  ),
                )
              else
                Icon(Icons.send_rounded, size: 16, color: colors.canvas),
              const SizedBox(width: 10),
              ResponsiveText(
                state.isSending
                    ? 'help_center.sending'
                    : 'help_center.send_cta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.canvas,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
