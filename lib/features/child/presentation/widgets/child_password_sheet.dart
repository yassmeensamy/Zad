import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import 'custom_modal.dart';

/// Bottom sheet that captures (or edits) the password for a single child
/// draft. Returns the entered password to the caller via [Navigator.pop],
/// or `null` if the user dismisses the sheet.
class ChildPasswordSheet extends StatefulWidget {
  const ChildPasswordSheet({
    super.key,
    required this.childName,
    this.initialPassword = '',
    this.minLength = 4,
  });

  final String childName;
  final String initialPassword;
  final int minLength;

  @override
  State<ChildPasswordSheet> createState() => _ChildPasswordSheetState();
}

class _ChildPasswordSheetState extends State<ChildPasswordSheet> {
  late final TextEditingController _controller;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text;
    if (value.length < widget.minLength) {
      setState(
        () => _error = 'create_profiles.password_too_short'.tr(
          args: [widget.minLength.toString()],
        ),
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fallbackName = 'create_profiles.password_sheet_fallback_name'.tr();
    final name = widget.childName.trim().isEmpty
        ? fallbackName
        : widget.childName.trim();
    return CustomModal(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      contentSpacing: 18,
      title: ResponsiveText(
        'create_profiles.password_sheet_title',
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: colors.oliveDeep,
        ),
      ),
      subtitle: Text(
        'create_profiles.password_sheet_sub'.tr(args: [name]),
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: AppColors.dateSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PasswordField(
            controller: _controller,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            hasError: _error != null,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.5,
                color: AppColors.date,
              ),
            ),
          ],
          const SizedBox(height: 18),
          AuthPrimaryButton(label: 'common.save', onTap: _save),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.hasError,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ZaadRadii.md),
        border: Border.all(
          color: hasError
              ? AppColors.date.withValues(alpha: 0.6)
              : colors.oliveSoft.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText(
                  'create_profiles.password_label',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 9 * 0.3,
                    color: colors.oliveSoft,
                  ),
                ),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  autofocus: true,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.oliveDeep,
                    letterSpacing: obscure ? 3 : 0,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'create_profiles.password_hint'.tr(),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.5,
                      color: colors.oliveSoft.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleObscure,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 18,
              color: colors.oliveSoft,
            ),
          ),
        ],
      ),
    );
  }
}
