import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_modal.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class DraftNoteSheet extends StatefulWidget {
  const DraftNoteSheet({super.key, this.initialNote, required this.onSubmit});

  final String? initialNote;
  final Future<bool> Function(String? note) onSubmit;

  /// Shows the sheet. Resolves to `true` once [onSubmit] succeeds,
  /// `false` if the user dismisses without submitting.
  static Future<bool> show(
    BuildContext context, {
    String? initialNote,
    required Future<bool> Function(String? note) onSubmit,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DraftNoteSheet(initialNote: initialNote, onSubmit: onSubmit),
    );
    return result ?? false;
  }

  @override
  State<DraftNoteSheet> createState() => _DraftNoteSheetState();
}

class _DraftNoteSheetState extends State<DraftNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    final note = text.isEmpty ? null : text;
    final ok = await widget.onSubmit(note);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomModal(
      title: ResponsiveText(
        'drafts.note_label',
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: colors.oliveDeep,
        ),
      ),
      subtitle: ResponsiveText(
        'drafts.note_hint',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: colors.textTertiary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              height: 1.5,
              color: colors.oliveDeep,
            ),
            decoration: InputDecoration(
              hintText: 'drafts.note_hint',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: colors.textTertiary,
              ),
              filled: true,
              fillColor: colors.canvasRaised.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.accent.withValues(alpha: 0.24),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.accent.withValues(alpha: 0.24),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.accentDeep.withValues(alpha: 0.6),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomButton.full(
            onTap: _save,
            theme: CustomButtonTheme(
              height: 48,
              backgroundColor: colors.oliveDeep,
              textColor: colors.canvas,
              borderRadius: 14,
            ),
            child: ResponsiveText(
              'drafts.note_save',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: colors.canvas,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
