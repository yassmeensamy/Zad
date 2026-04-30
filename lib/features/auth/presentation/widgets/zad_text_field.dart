import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/textforms/main_text_form.dart';
import '../../../../theme/theme.dart';

/// Login-style field. Visual tokens (fill, borders, hint, icon colors)
/// come from the global [InputDecorationTheme] in `AppTheme`.
class ZadTextField extends StatelessWidget {
  const ZadTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.passwordToggle = false,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool passwordToggle;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return MainTextFormField(
      controller: controller,
      hintText: hintText.tr(),
      prefixIcon: prefixIcon,
      keyboardType: keyboardType,
      obscureText: obscureText,
      passwordToggle: passwordToggle,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: autovalidateMode,
      iconSize: 20,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.oliveDeep,
      ),
    );
  }
}
