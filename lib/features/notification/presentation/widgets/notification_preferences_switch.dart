import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../theme/theme.dart';
import '../cubit/notification_preferences_cubit.dart';
import '../cubit/notification_preferences_state.dart';

/// Master "push notifications" toggle used as the trailing control of a profile
/// menu item. Self-contained: it owns its [NotificationPreferencesCubit] so the
/// item can be dropped into the section list without the screen wiring a
/// provider, and the cubit is only created when the item actually renders.
class NotificationPreferencesSwitch extends StatelessWidget {
  const NotificationPreferencesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationPreferencesCubit>(
      create: (_) => sl<NotificationPreferencesCubit>()..load(),
      child: const _NotificationPreferencesSwitchView(),
    );
  }
}

class _NotificationPreferencesSwitchView extends StatelessWidget {
  const _NotificationPreferencesSwitchView();

  Future<void> _promptOpenSettings(BuildContext context) async {
    final cubit = context.read<NotificationPreferencesCubit>();
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: Icons.notifications_off_outlined,
      titleKey: 'notifications.permission_required_title',
      messageKey: 'notifications.permission_required_subtitle',
      confirmKey: 'notifications.open_settings',
    );
    if (confirmed == true) await cubit.openSystemSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocConsumer<NotificationPreferencesCubit,
        NotificationPreferencesState>(
      listenWhen: (prev, curr) =>
          prev.actionError != curr.actionError ||
          prev.permissionBlocked != curr.permissionBlocked,
      listener: (context, state) {
        final cubit = context.read<NotificationPreferencesCubit>();
        if (state.actionError != null) {
          SnackBarHelper.showError(context, message: state.actionError!);
          cubit.clearActionError();
        }
        if (state.permissionBlocked) {
          cubit.clearPermissionBlocked();
          _promptOpenSettings(context);
        }
      },
      builder: (context, state) {
        // The switch is always interactive (its dot is clickable) — even during
        // the initial load — and only locks while a write is in flight. Light
        // tinted tracks keep it soft against the menu card.
        return Switch.adaptive(
          value: state.enabled,
          onChanged: state.updating
              ? null
              : (value) =>
                  context.read<NotificationPreferencesCubit>().setEnabled(value),
          thumbColor: WidgetStatePropertyAll(colors.canvas),
          activeTrackColor: colors.accent.withValues(alpha: 0.45),
          inactiveTrackColor: colors.olive.withValues(alpha: 0.15),
          trackOutlineColor: WidgetStatePropertyAll(
            colors.accent.withValues(alpha: 0.25),
          ),
        );
      },
    );
  }
}
