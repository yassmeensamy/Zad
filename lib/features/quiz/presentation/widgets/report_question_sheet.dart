import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/textforms/main_text_form.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// The composed report a user submits about a question: the chosen reason key
/// plus an optional free-text description.
typedef QuestionReport = ({String reasonKey, String message});

/// Bottom sheet to report a problem with a question. Collects a reason and an
/// optional description, then returns them so the caller can open a support
/// ticket. Returns `null` if dismissed.
class ReportQuestionSheet extends StatefulWidget {
  const ReportQuestionSheet({super.key});

  static const _reasons = <_ReportReason>[
    _ReportReason(
      key: 'quiz.report.reason_wrong_answer',
      icon: Icons.report_outlined,
    ),
    _ReportReason(
      key: 'quiz.report.reason_unclear',
      icon: Icons.question_mark_rounded,
    ),
    _ReportReason(
      key: 'quiz.report.reason_typo',
      icon: Icons.text_fields_rounded,
    ),
    _ReportReason(
      key: 'quiz.report.reason_other',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  static Future<QuestionReport?> show(BuildContext context) {
    return showModalBottomSheet<QuestionReport>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReportQuestionSheet(),
    );
  }

  @override
  State<ReportQuestionSheet> createState() => _ReportQuestionSheetState();
}

class _ReportQuestionSheetState extends State<ReportQuestionSheet> {
  final _messageController = TextEditingController();
  String? _selectedReason;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _select(String key) => setState(() => _selectedReason = key);

  void _submit() {
    final reason = _selectedReason;
    if (reason == null) return;
    Navigator.of(context).pop(
      (reasonKey: reason, message: _messageController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.canvas,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ZaadRadii.dialog),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                ResponsiveText(
                  'quiz.report.title',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                for (final reason in ReportQuestionSheet._reasons)
                  _ReasonTile(
                    reason: reason,
                    selected: _selectedReason == reason.key,
                    onTap: () => _select(reason.key),
                  ),
                const SizedBox(height: 12),
                MainTextFormField(
                  controller: _messageController,
                  hintText: 'quiz.report.message_hint'.tr(),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 18),
                CustomButton.full(
                  enabled: _selectedReason != null,
                  onTap: _submit,
                  theme: CustomButtonTheme(
                    height: 52,
                    backgroundColor: colors.olive,
                    textColor: colors.canvas,
                    borderRadius: 14,
                  ),
                  child: ResponsiveText(
                    'quiz.report.submit',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      color: colors.canvas,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final _ReportReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = colors.olive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ZaadRadii.lgAll,
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.08)
                  : colors.canvasRaised.withValues(alpha: 0.7),
              borderRadius: ZaadRadii.lgAll,
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : colors.borderSubtle,
                width: selected ? 1.2 : 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
              child: Row(
                children: [
                  Icon(
                    reason.icon,
                    size: 18,
                    color: selected ? accent : colors.oliveDeep,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ResponsiveText(
                      reason.key,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: selected ? accent : colors.textTertiary,
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
