import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../notification/presentation/cubit/notification_preferences_cubit.dart';
import '../../../notification/presentation/cubit/notification_preferences_state.dart';

/// Home banner warning that push notifications cannot reach the user — either
/// the OS permission is missing or every notification type is muted in the
/// user's preferences.
///
/// Reads the [NotificationPreferencesCubit] the home screen provides (rather
/// than owning one) so scrolling it out of the lazy sliver list doesn't re-fire
/// the preferences fetch. It collapses to nothing — including its own bottom
/// spacing — once notifications are on, so the surrounding list needs no
/// conditional gap.
class HomeNotificationWarning extends StatefulWidget {
  const HomeNotificationWarning({super.key});

  @override
  State<HomeNotificationWarning> createState() =>
      _HomeNotificationWarningState();
}

class _HomeNotificationWarningState extends State<HomeNotificationWarning>
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

  /// Re-reads the live OS permission on resume so the banner disappears as soon
  /// as the user grants it from the settings page we sent them to.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

  /// Missing OS permission goes straight to the settings page (the CTA already
  /// says so); a muted-preferences banner just flips every type back on — and
  /// falls back to the settings prompt if the permission vanished meanwhile.
  void _onTap(NotificationPreferencesState state) {
    final cubit = context.read<NotificationPreferencesCubit>();
    if (!state.permissionGranted) {
      cubit.openSystemSettings();
      return;
    }
    cubit.setEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
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
        // Stay silent until we actually know the answer: a failed load (guest
        // or offline) must not accuse the user of muting anything.
        if (!state.isLoaded) return const SizedBox.shrink();

        final permissionMissing = !state.permissionGranted;
        if (!permissionMissing && state.preferences.anyEnabled) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _WarningCard(
            permissionMissing: permissionMissing,
            updating: state.updating,
            onTap: () => _onTap(state),
          ),
        );
      },
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.permissionMissing,
    required this.updating,
    required this.onTap,
  });

  /// `true` when the OS permission is the blocker, `false` when the permission
  /// is granted but every type is muted in the user's preferences.
  final bool permissionMissing;
  final bool updating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final titleKey = permissionMissing
        ? 'home.notifications_warning.permission_title'
        : 'home.notifications_warning.preferences_title';
    final subtitleKey = permissionMissing
        ? 'home.notifications_warning.permission_subtitle'
        : 'home.notifications_warning.preferences_subtitle';
    final ctaKey = permissionMissing
        ? 'notifications.open_settings'
        : 'home.notifications_warning.enable';

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: updating ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: ZaadRadii.xlAll,
            color: colors.cardSurface,
            border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: ZaadRadii.mdAll,
                    color: colors.warning.withValues(alpha: 0.14),
                    border: Border.all(
                      color: colors.warning.withValues(alpha: 0.28),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 19,
                    color: colors.warning,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResponsiveText(
                        titleKey,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: 0,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ResponsiveText(
                        subtitleKey,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          height: 1.3,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ActionPill(labelKey: ctaKey, updating: updating),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual affordance only — the whole card carries the tap.
class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.labelKey, required this.updating});

  final String labelKey;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 30,
      constraints: const BoxConstraints(minWidth: 62),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.pillAll,
        color: colors.warning.withValues(alpha: updating ? 0.10 : 0.18),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: updating
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.warning,
              ),
            )
          : ResponsiveText(
              labelKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: colors.warning,
              ),
            ),
    );
  }
}
