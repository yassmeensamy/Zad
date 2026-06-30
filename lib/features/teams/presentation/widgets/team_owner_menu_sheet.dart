import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Owner-only actions surfaced from the team-home overflow button.
enum TeamOwnerAction { transfer, leave }

/// Small action sheet shown to the team owner. Resolves with the chosen
/// [TeamOwnerAction], or `null` if dismissed.
Future<TeamOwnerAction?> showTeamOwnerMenu(BuildContext context) {
  return showModalBottomSheet<TeamOwnerAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
    builder: (_) => const _OwnerMenuSheet(),
  );
}

class _OwnerMenuSheet extends StatelessWidget {
  const _OwnerMenuSheet();

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
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.oliveDeep.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: ResponsiveText(
                  'teams.transfer.menu_title'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: colors.oliveSoft,
                  ),
                ),
              ),
              _MenuRow(
                icon: Icons.workspace_premium_rounded,
                label: 'teams.transfer.menu_transfer'.tr(),
                color: colors.goldDeep,
                onTap: () => context.pop(TeamOwnerAction.transfer),
              ),
              const SizedBox(height: 8),
              _MenuRow(
                icon: Icons.logout_rounded,
                label: 'teams.transfer.menu_leave'.tr(),
                color: colors.warning,
                onTap: () => context.pop(TeamOwnerAction.leave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.overlayLight,
      borderRadius: ZaadRadii.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: ZaadRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: ZaadRadii.lgAll,
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: ResponsiveText(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.oliveDeep,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.oliveSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
