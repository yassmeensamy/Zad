import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';

const _kBulletKeys = <String>[
  'teams.leave.warning_bullet_1',
  'teams.leave.warning_bullet_2',
  'teams.leave.warning_bullet_3',
];

/// Bottom sheet that warns about the consequences of leaving the team.
/// Confirming inside the sheet submits the leave request; resolves with
/// `true` once the request succeeds.
Future<bool> showTeamLeaveSheet(BuildContext context) async {
  final cubit = context.read<TeamsCubit>();
  cubit.resetLeaveState();

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<TeamsCubit>.value(
      value: cubit,
      child: const _TeamLeaveSheet(),
    ),
  );
  return result ?? false;
}

class _TeamLeaveSheet extends StatelessWidget {
  const _TeamLeaveSheet();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.leaveStatus != b.leaveStatus,
      listener: (context, state) {
        if (state.leaveStatus == LeaveStatus.success) {
          context.pop(true);
        }
      },
      builder: (context, state) {
        final submitting = state.leaveStatus == LeaveStatus.submitting;
        final errorMessage = state.leaveStatus == LeaveStatus.error
            ? state.errorMessage
            : null;

        return PopScope(
          canPop: !submitting,
          child: _SheetShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GrabHandle(),
                const SizedBox(height: 16),
                const _WarningHeader(),
                const SizedBox(height: 14),
                for (final key in _kBulletKeys) _WarningBullet(localeKey: key),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _ErrorText(message: errorMessage),
                ],
                const SizedBox(height: 8),
                ZaadPrimaryButton(
                  label: 'teams.leave.warning_cta'.tr(),
                  onTap: context.read<TeamsCubit>().leaveTeam,
                  enabled: !submitting,
                  loading: submitting,
                  variant: ZaadButtonVariant.danger,
                ),
                const SizedBox(height: 8),
                _StayButton(
                  enabled: !submitting,
                  onTap: () => context.pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.canvas, colors.sheetSurface],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: colors.olive.withValues(alpha: 0.18)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep.withValues(alpha: 0.3),
            blurRadius: 50,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: child,
        ),
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colors.oliveDeep.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _WarningHeader extends StatelessWidget {
  const _WarningHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.warningSurface,
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            Icons.logout_rounded,
            size: 20,
            color: colors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                'teams.leave.warning_title'.tr(),
                style: AppTextStyles.titleLarge.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.oliveDeep,
                ),
              ),
              const SizedBox(height: 4),
              ResponsiveText(
                'teams.leave.warning_arabic'.tr(),
                style: ZaadType.bodySmall.copyWith(color: colors.textArabic),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarningBullet extends StatelessWidget {
  const _WarningBullet({required this.localeKey});

  final String localeKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, end: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.olive.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: ResponsiveText(
              localeKey.tr(),
              style: AppTextStyles.bodySmall.copyWith(color: colors.olive),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      message.tr(),
      textAlign: TextAlign.center,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.colorScheme.error,
      ),
    );
  }
}

class _StayButton extends StatelessWidget {
  const _StayButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.olive, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: ZaadRadii.lgAll),
        minimumSize: const Size.fromHeight(48),
      ),
      child: ResponsiveText(
        'teams.leave.warning_stay'.tr().toUpperCase(),
        style: ZaadType.ctaCompact.copyWith(color: colors.oliveDeep),
      ),
    );
  }
}
