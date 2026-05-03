import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Bottom sheet to report an issue with a question. Returns the chosen
/// reason key (or null if dismissed).
class ReportQuestionSheet extends StatelessWidget {
  const ReportQuestionSheet({super.key});

  static const _reasons = <_ReportReason>[
    _ReportReason(key: 'quiz.report.reason_wrong_answer', icon: Icons.report_outlined),
    _ReportReason(key: 'quiz.report.reason_unclear', icon: Icons.question_mark_rounded),
    _ReportReason(key: 'quiz.report.reason_typo', icon: Icons.text_fields_rounded),
    _ReportReason(key: 'quiz.report.reason_other', icon: Icons.more_horiz_rounded),
  ];

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReportQuestionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ZaadRadii.dialog),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'quiz.report.title'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              for (final reason in _reasons) _reasonTile(context, reason),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reasonTile(BuildContext context, _ReportReason reason) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(reason.key),
          borderRadius: ZaadRadii.lgAll,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.canvasRaised.withValues(alpha: 0.7),
              borderRadius: ZaadRadii.lgAll,
              border: Border.all(color: colors.borderSubtle, width: 0.8),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
              child: Row(
                children: [
                  Icon(reason.icon, size: 18, color: colors.oliveDeep),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason.key.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportReason {
  const _ReportReason({required this.key, required this.icon});
  final String key;
  final IconData icon;
}
