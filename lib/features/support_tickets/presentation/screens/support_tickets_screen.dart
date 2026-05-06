import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_shimmer.dart';
import '../../../../theme/theme.dart';
import '../../data/models/support_topic_enum.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/ticket_status_enum.dart';
import '../cubit/support_tickets_cubit.dart';
import '../cubit/support_tickets_state.dart';
import '../widgets/ticket_card.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupportTicketsCubit>(
      create: (_) => sl<SupportTicketsCubit>()..load(),
      child: const _SupportTicketsView(),
    );
  }
}

class _SupportTicketsView extends StatelessWidget {
  const _SupportTicketsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZaadAppBar(
        title: 'support_tickets.title',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.olive,
        foregroundColor: colors.canvas,
        onPressed: () => context.pushNamed(AppRoutes.helpCenterName),
        icon: const Icon(Icons.add_rounded),
        label: const ResponsiveText('support_tickets.new_ticket'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SupportTicketsCubit, SupportTicketsState>(
            listenWhen: (a, b) =>
                a.errorMessage != b.errorMessage && b.errorMessage != null,
            listener: (context, state) {
              SnackBarHelper.showError(
                context,
                message: state.errorMessage!,
              );
            },
          ),
          BlocListener<SupportTicketsCubit, SupportTicketsState>(
            listenWhen: (a, b) =>
                a.crudStatus != b.crudStatus &&
                b.crudStatus == SupportTicketsCrudStatus.error,
            listener: (context, state) {
              SnackBarHelper.showError(
                context,
                message: state.crudErrorMessage ?? 'errors.generic',
              );
            },
          ),
        ],
        child: BlocBuilder<SupportTicketsCubit, SupportTicketsState>(
          buildWhen: (a, b) => a.status != b.status || a.tickets != b.tickets,
          builder: (context, state) {
            if (state.isError) {
              return ErrorState(
                message: state.errorMessage ?? 'support_tickets.load_failed',
                onRetry: () => context.read<SupportTicketsCubit>().load(),
              );
            }
            final isLoading = state.isInitial || state.isLoading;
            if (!isLoading && !state.hasTickets) {
              return _Empty(
                onCompose: () =>
                    context.pushNamed(AppRoutes.helpCenterName),
              );
            }
            final tickets = isLoading ? _placeholderTickets : state.tickets;
            return RefreshIndicator(
              color: colors.olive,
              onRefresh: () =>
                  context.read<SupportTicketsCubit>().load(isRefresh: true),
              child: Skeletonizer(
                enabled: isLoading,
                effect: appShimmerEffect(colors),
                child: ListView.builder(
                  physics: isLoading
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return TicketCard(
                      ticket: ticket,
                      onTap: isLoading ? null : () => _onView(context, ticket),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onView(BuildContext context, TicketModel ticket) {
    context.pushNamed(
      AppRoutes.ticketDetailName,
      pathParameters: {'id': ticket.id},
      extra: (
        cubit: context.read<SupportTicketsCubit>(),
        ticket: ticket,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCompose});

  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return EmptyState(
      icon: Icons.support_agent_outlined,
      title: 'support_tickets.empty_title',
      subtitle: 'support_tickets.empty_subtitle',
      action: FilledButton.icon(
        onPressed: onCompose,
        style: FilledButton.styleFrom(
          backgroundColor: colors.olive,
          foregroundColor: colors.canvas,
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const ResponsiveText('support_tickets.new_ticket'),
      ),
    );
  }
}

final _placeholderTickets = List<TicketModel>.generate(
  4,
  (i) => TicketModel(
    id: 'placeholder-$i',
    userId: '',
    userEmail: '',
    userDisplayName: '',
    topic: SupportTopicEnum.values[i % SupportTopicEnum.values.length],
    title: 'Lorem ipsum dolor sit amet consectetur adipiscing elit',
    body: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
    status: TicketStatusEnum.open,
    replyCount: 0,
    createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
  ),
);
