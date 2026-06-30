import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../../data/models/team_member_model.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';

/// Member-picker bottom sheet for handing team ownership to someone else.
/// Selecting a member raises a confirmation dialog; confirming submits the
/// transfer. Resolves with the new owner's name once it succeeds, or `null`
/// if the owner backs out or it fails.
Future<String?> showTransferOwnershipSheet(BuildContext context) async {
  final cubit = context.read<TeamsCubit>();
  cubit.resetTransferState();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<TeamsCubit>.value(
      value: cubit,
      child: const _TransferSheet(),
    ),
  );
}

class _TransferSheet extends StatefulWidget {
  const _TransferSheet();

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  /// The member currently being transferred to — drives the per-row spinner
  /// and is returned to the caller so it can announce the new owner.
  String? _pendingId;
  String? _pendingName;

  @override
  void initState() {
    super.initState();
    // Members power the picker; pull them if the home view hasn't already.
    final cubit = context.read<TeamsCubit>();
    if (cubit.state.members == null) cubit.loadTeamMembers();
  }

  Future<void> _onPick(BuildContext context, TeamMemberModel member) async {
    final confirmed = await _confirmTransfer(context, member.username);
    if (!confirmed || !context.mounted) return;
    setState(() {
      _pendingId = member.userId;
      _pendingName = member.username;
    });
    context.read<TeamsCubit>().transferOwnership(member.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.transferStatus != b.transferStatus,
      listener: (context, state) {
        if (state.transferStatus == TransferStatus.success) {
          context.pop(_pendingName);
        } else if (state.transferStatus == TransferStatus.error) {
          setState(() => _pendingId = null);
        }
      },
      builder: (context, state) {
        final submitting = state.transferStatus == TransferStatus.submitting;
        final candidates = [
          for (final m in state.members?.members ?? const <TeamMemberModel>[])
            if (!m.isOwner) m,
        ];
        final errorMessage = state.transferStatus == TransferStatus.error
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
                const _Header(),
                const SizedBox(height: 16),
                if (candidates.isEmpty)
                  const _EmptyState()
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final m in candidates)
                            _MemberRow(
                              member: m,
                              loading: _pendingId == m.userId,
                              enabled: !submitting,
                              onTap: () => _onPick(context, m),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  _ErrorText(message: errorMessage),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Themed confirmation dialog shown before the transfer is submitted.
Future<bool> _confirmTransfer(BuildContext context, String name) async {
  final colors = context.appColors;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
    builder: (dialogContext) => Dialog(
      backgroundColor: colors.sheetSurface,
      shape: RoundedRectangleBorder(borderRadius: ZaadRadii.xlAll),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.goldLight.withValues(alpha: 0.4),
                border: Border.all(
                  color: colors.goldDeep.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 22,
                color: colors.goldDeep,
              ),
            ),
            const SizedBox(height: 14),
            ResponsiveText(
              'teams.transfer.confirm_title'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              'teams.transfer.confirm_lede'.tr(namedArgs: {'name': name}),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.oliveSoft,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ZaadPrimaryButton(
              label: 'teams.transfer.confirm_cta'.tr(),
              onTap: () => dialogContext.pop(true),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: ResponsiveText(
                'teams.transfer.cancel'.tr(),
                style: ZaadType.ctaCompact.copyWith(color: colors.oliveDeep),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'teams.transfer.picker_title'.tr(),
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          'teams.transfer.picker_lede'.tr(),
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.oliveSoft,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final TeamMemberModel member;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = member.username.trim();
    final letter = name.isEmpty ? '—' : name.substring(0, 1).toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: ZaadRadii.lgAll,
          color: colors.overlayLight,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.goldLight.withValues(alpha: 0.35),
                border: Border.all(
                  color: colors.goldDeep.withValues(alpha: 0.3),
                ),
              ),
              child: ResponsiveText(
                letter,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.goldDeep,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ResponsiveText(
                name.isEmpty ? 'Member' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.oliveDeep,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _MakeOwnerButton(
              loading: loading,
              enabled: enabled,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _MakeOwnerButton extends StatelessWidget {
  const _MakeOwnerButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.goldDeep.withValues(alpha: 0.55)),
        shape: RoundedRectangleBorder(borderRadius: ZaadRadii.smAll),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: loading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.goldDeep,
              ),
            )
          : ResponsiveText(
              'teams.transfer.make_owner'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.goldDeep,
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: ResponsiveText(
        'teams.transfer.picker_empty'.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(color: colors.oliveSoft),
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

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
