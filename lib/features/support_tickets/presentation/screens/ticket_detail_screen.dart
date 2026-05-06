import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/relative_time.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_shimmer.dart';
import '../../../../theme/theme.dart';
import '../../data/models/reply_model.dart';
import '../../data/models/support_topic_enum.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/ticket_status_enum.dart';
import '../cubit/support_tickets_cubit.dart';
import '../cubit/support_tickets_state.dart';
import '../widgets/conversation_bubble.dart';
import '../widgets/reply_bubble.dart';
import '../widgets/ticket_status_chip.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId, this.seed});

  final String ticketId;

  final TicketModel? seed;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SupportTicketsCubit>().loadDetail(widget.ticketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZaadAppBar(
        title: 'support_tickets.detail.title',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SupportTicketsCubit, SupportTicketsState>(
            listenWhen: (a, b) =>
                a.detailErrorMessage != b.detailErrorMessage &&
                b.detailErrorMessage != null,
            listener: (context, state) {
              SnackBarHelper.showError(
                context,
                message: state.detailErrorMessage!,
              );
            },
          ),
          BlocListener<SupportTicketsCubit, SupportTicketsState>(
            listenWhen: (a, b) => a.crudStatus != b.crudStatus,
            listener: (context, state) {
              if (state.crudStatus == SupportTicketsCrudStatus.closed) {
                SnackBarHelper.showSuccess(
                  context,
                  message: 'support_tickets.detail.close_success'.tr(),
                );
              } else if (state.crudStatus ==
                  SupportTicketsCrudStatus.error) {
                SnackBarHelper.showError(
                  context,
                  message: state.crudErrorMessage ??
                      'support_tickets.detail.close_failed',
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SupportTicketsCubit, SupportTicketsState>(
          buildWhen: (a, b) =>
              a.detailStatus != b.detailStatus ||
              a.selectedTicket != b.selectedTicket,
          builder: (context, state) {
            if (state.isDetailError &&
                state.selectedTicket == null &&
                widget.seed == null) {
              return ErrorState(
                message: state.detailErrorMessage ??
                    'support_tickets.load_failed',
                onRetry: () => context
                    .read<SupportTicketsCubit>()
                    .loadDetail(widget.ticketId),
              );
            }
            final realTicket = state.selectedTicket ?? widget.seed;
            final isLoading = realTicket == null;
            final ticket = realTicket ?? _placeholderTicket;
            return RefreshIndicator(
              color: colors.olive,
              onRefresh: () => context
                  .read<SupportTicketsCubit>()
                  .loadDetail(widget.ticketId),
              child: Skeletonizer(
                enabled: isLoading,
                effect: appShimmerEffect(colors),
                child: ListView(
                  physics: isLoading
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  children: [
                    _HeroHeader(ticket: ticket),
                    const SizedBox(height: 26),
                    _ConversationThread(
                      ticket: ticket,
                      status: state.detailStatus,
                    ),
                    if (!isLoading) ...[
                      const SizedBox(height: 24),
                      _CloseFooter(ticketId: widget.ticketId),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.ticket});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = ticket.topic.accent(colors);
    final relativeCreated = formatRelative(context, ticket.createdAt);
    final shortRef = ticket.id.length > 6
        ? ticket.id.substring(0, 6).toUpperCase()
        : ticket.id.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            colors.canvasRaised.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(ZaadRadii.xxl),
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconHalo(icon: ticket.topic.icon, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      ticket.topic.label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TicketStatusChip(status: ticket.status),
                  ],
                ),
              ),
              _RefPill(shortRef: shortRef),
            ],
          ),
          if (ticket.title.isNotEmpty) ...[
            const SizedBox(height: 18),
            ResponsiveText(
              ticket.title,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.oliveDeep,
                height: 1.25,
                letterSpacing: -0.2,
              ),
            ),
          ],
          if (relativeCreated != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 6),
                ResponsiveText(
                  relativeCreated,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11.5,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconHalo extends StatelessWidget {
  const _IconHalo({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: colors.canvas),
    );
  }
}

class _RefPill extends StatelessWidget {
  const _RefPill({required this.shortRef});

  final String shortRef;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            'support_tickets.detail.ref_label',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            shortRef,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.4,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationThread extends StatelessWidget {
  const _ConversationThread({required this.ticket, required this.status});

  final TicketModel ticket;
  final TicketDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final replies = ticket.replies;
    final loading = status == TicketDetailStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              'support_tickets.detail.replies_section',
              style: ZaadType.sectionLabel.copyWith(color: colors.oliveDeep),
            ),
            const Spacer(),
            if (replies.isNotEmpty)
              ResponsiveText(
                'support_tickets.reply_count'
                    .plural(replies.length, args: ['${replies.length}']),
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textTertiary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ConversationBubble(
          authorLabel: 'support_tickets.detail.original_message',
          body: ticket.body,
          accent: colors.accent,
          icon: Icons.person_outline_rounded,
          createdAt: ticket.createdAt,
        ),
        if (loading && replies.isEmpty)
          Skeletonizer(
            effect: appShimmerEffect(colors),
            child: Column(
              children: _placeholderReplies
                  .map((r) => ReplyBubble(reply: r))
                  .toList(),
            ),
          )
        else if (replies.isEmpty)
          const _NoRepliesYet()
        else
          ...replies.map((r) => ReplyBubble(reply: r)),
      ],
    );
  }
}

class _NoRepliesYet extends StatelessWidget {
  const _NoRepliesYet();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.olive.withValues(alpha: 0.08),
              border: Border.all(
                color: colors.olive.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 16,
              color: colors.oliveDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ResponsiveText(
                'support_tickets.detail.no_replies',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  height: 1.45,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseFooter extends StatelessWidget {
  const _CloseFooter({required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportTicketsCubit, SupportTicketsState>(
      buildWhen: (a, b) =>
          a.selectedTicket?.status != b.selectedTicket?.status ||
          a.mutatingIds != b.mutatingIds,
      builder: (context, state) {
        final ticket = state.selectedTicket;
        if (ticket == null || ticket.id != ticketId) {
          return const SizedBox.shrink();
        }
        if (ticket.status.isClosed) return const SizedBox.shrink();

        final colors = context.appColors;
        final mutating = state.isMutating(ticketId);
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: colors.canvasRaised.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(ZaadRadii.xl),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: colors.oliveDeep,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'support_tickets.detail.close_card_lead',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.oliveDeep,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      'support_tickets.detail.close_card_body',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CustomButton(
                onTap: mutating
                    ? null
                    : () => _confirmAndClose(context, ticketId),
                enabled: !mutating,
                loading: mutating,
                text: 'support_tickets.detail.close_ticket',
                theme: CustomButtonTheme(
                  height: 38,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  backgroundColor: colors.oliveDeep,
                  textColor: Colors.white,
                  borderRadius: ZaadRadii.md,
                  textStyle: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmAndClose(BuildContext context, String id) async {
  final cubit = context.read<SupportTicketsCubit>();
  final confirmed = await CustomDialog.show<bool>(
    context: context,
    child: const _CloseConfirmDialog(),
  );
  if (confirmed != true || !context.mounted) return;
  await cubit.closeTicket(id);
}

class _CloseConfirmDialog extends StatelessWidget {
  const _CloseConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.olive.withValues(alpha: 0.10),
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: colors.oliveDeep,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        ResponsiveText(
          'support_tickets.detail.close_confirm_title',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          'support_tickets.detail.close_confirm_body',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton.full(
          onTap: () => Navigator.of(context).pop(true),
          text: 'support_tickets.detail.close_ticket',
          theme: CustomButtonTheme(
            height: 48,
            backgroundColor: colors.oliveDeep,
            textColor: Colors.white,
            borderRadius: ZaadRadii.lg,
            textStyle: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: ResponsiveText(
            'common.cancel',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

final _placeholderTicket = TicketModel(
  id: 'placeholder-ticket-id',
  userId: '',
  userEmail: '',
  userDisplayName: '',
  topic: SupportTopicEnum.question,
  title: 'Lorem ipsum dolor sit amet consectetur',
  body: 'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
      'Quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo.',
  status: TicketStatusEnum.open,
  createdAt: DateTime.now().subtract(const Duration(hours: 3)),
);

final _placeholderReplies = [
  ReplyModel(
    id: 1,
    content: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
    adminReply: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ReplyModel(
    id: 2,
    content: 'Sed do eiusmod tempor incididunt ut labore et dolore magna.',
    adminReply: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
];

