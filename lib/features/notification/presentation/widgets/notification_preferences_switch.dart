import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../theme/theme.dart';
import '../cubit/notification_preferences_cubit.dart';
import '../cubit/notification_preferences_state.dart';

/// Master "push notifications" toggle used as the trailing control of a profile
/// menu item. Self-contained: it attaches the shared
/// [NotificationPreferencesCubit] itself so the item can be dropped into the
/// section list without the screen wiring a provider.
///
/// The cubit is a singleton shared with the home warning banner — hence
/// `.value` (this widget must not close it) and [ensureLoaded] (whichever
/// surface renders first does the fetch).
class NotificationPreferencesSwitch extends StatelessWidget {
  const NotificationPreferencesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationPreferencesCubit>.value(
      value: sl<NotificationPreferencesCubit>()..ensureLoaded(),
      child: const _NotificationPreferencesSwitchView(),
    );
  }
}

class _NotificationPreferencesSwitchView extends StatefulWidget {
  const _NotificationPreferencesSwitchView();

  @override
  State<_NotificationPreferencesSwitchView> createState() =>
      _NotificationPreferencesSwitchViewState();
}

class _NotificationPreferencesSwitchViewState
    extends State<_NotificationPreferencesSwitchView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the user returns from the OS settings page (or any other resume),
  /// re-reconcile the toggle with the live permission so a just-granted
  /// permission finishes the enable the user asked for.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.debug('NotificationPreferencesSwitch lifecycle: $state');
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<NotificationPreferencesCubit>().syncAfterResume();
    }
  }

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
