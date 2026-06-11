import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'custom_dialog.dart';
import 'responsive_text.dart';
import 'zaad_primary_button.dart';

/// App-update prompt. When [isForceUpdate] is true the dialog is non-dismissible
/// (no barrier dismiss, no system back, single "Update now" action). Otherwise
/// it adds a "Later" action and can be dismissed.
class UpgradeDialog {
  const UpgradeDialog._();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onUpdate,
    String? currentVersion,
    String? newVersion,
    bool isForceUpdate = false,
    String? releaseNotes,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (_) => PopScope(
        canPop: !isForceUpdate,
        child: CustomDialog(
          child: _UpgradeDialogContent(
            onUpdate: onUpdate,
            currentVersion: currentVersion,
            newVersion: newVersion,
            isForceUpdate: isForceUpdate,
            releaseNotes: releaseNotes,
          ),
        ),
      ),
    );
  }
}

class _UpgradeDialogContent extends StatelessWidget {
  const _UpgradeDialogContent({
    required this.onUpdate,
    required this.isForceUpdate,
    this.currentVersion,
    this.newVersion,
    this.releaseNotes,
  });

  final VoidCallback onUpdate;
  final bool isForceUpdate;
  final String? currentVersion;
  final String? newVersion;
  final String? releaseNotes;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final description = (releaseNotes != null && releaseNotes!.trim().isNotEmpty)
        ? releaseNotes!.trim()
        : 'update.description'.tr();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isForceUpdate)
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(
                Icons.close_rounded,
                size: 22,
                color: colors.textSecondary,
              ),
            ),
          ),
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.ctaTop, colors.ctaBottom],
            ),
          ),
          child: Icon(
            Icons.system_update_rounded,
            size: 36,
            color: colors.onCta,
          ),
        ),
        const SizedBox(height: 20),
        ResponsiveText(
          'update.title'.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ResponsiveText(
          description,
          textAlign: TextAlign.center,
          maxLines: 5,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        if (currentVersion != null && newVersion != null) ...[
          const SizedBox(height: 18),
          _VersionBadge(
            currentVersion: currentVersion!,
            newVersion: newVersion!,
          ),
        ],
        const SizedBox(height: 24),
        ZaadPrimaryButton(
          label: 'update.update_now'.tr(),
          leadingIcon: Icons.download_rounded,
          onTap: onUpdate,
        ),
        if (!isForceUpdate) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: ResponsiveText(
              'update.later'.tr(),
              style: AppTextStyles.labelLarge.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.currentVersion, required this.newVersion});

  final String currentVersion;
  final String newVersion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(ZaadRadii.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _VersionChip(label: currentVersion, color: colors.textSecondary),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: colors.textTertiary,
            ),
          ),
          _VersionChip(label: newVersion, color: colors.olive, bold: true),
        ],
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.color,
    this.bold = false,
  });

  final String label;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      'v$label',
      style: AppTextStyles.labelMedium.copyWith(
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
