import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (_) => sl<NotificationCubit>()..openInbox(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView>
    with ScrollPaginationMixin {
  @override
  void onLoadMore() => context.read<NotificationCubit>().loadMore();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppScaffold(
      appBar: ZaadAppBar(
        title: 'notifications.title',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: BlocListener<NotificationCubit, NotificationState>(
        listenWhen: (a, b) => a.actionError != b.actionError,
        listener: (context, state) {
          if (state.actionError == null) return;
          SnackBarHelper.showError(context, message: state.actionError!);
          context.read<NotificationCubit>().clearActionError();
        },
        child: BlocBuilder<NotificationCubit, NotificationState>(
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.notifications != b.notifications ||
              a.loadingMore != b.loadingMore,
          builder: (context, state) {
            if (state.isInitial || state.isLoading) {
              return const _LoadingSkeleton();
            }
            if (state.isError) {
              return ErrorState(
                message: state.errorMessage ?? 'notifications.load_failed',
                onRetry: () =>
                    context.read<NotificationCubit>().getNotifications(),
              );
            }
            if (!state.hasNotifications) {
              return const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'notifications.empty_title',
                subtitle: 'notifications.empty_subtitle',
              );
            }
            return RefreshIndicator(
              color: colors.olive,
              onRefresh: () => context
                  .read<NotificationCubit>()
                  .getNotifications(refresh: true),
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return const _PaginationLoader();
                  }
                  final notification = state.notifications[index];
                  return NotificationCard(
                    key: ValueKey(notification.id),
                    notification: notification,
                    onDelete: () => context
                        .read<NotificationCubit>()
                        .deleteNotification(notification.id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaginationLoader extends StatelessWidget {
  const _PaginationLoader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: colors.olive),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  static final _mock = List<NotificationModel>.generate(
    5,
    (i) => NotificationModel(
      id: -i - 1,
      notificationType: NotificationTypeEnum.values[i %
          NotificationTypeEnum.values.length],
      title: 'A placeholder notification title',
      messageBody:
          'A short body line that mimics the look of a real notification while loading.',
      sentAt: DateTime.now().subtract(Duration(minutes: (i + 1) * 7)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: _mock.length,
        itemBuilder: (_, i) => NotificationCard(notification: _mock[i]),
      ),
    );
  }
}
