import 'package:easy_localization/easy_localization.dart';

import 'main_text_form.dart';

class CustomTextFormField extends MainTextFormField {
  CustomTextFormField({
    super.key,
    super.controller,
    super.focusNode,
    String? hintText,
    super.contentPadding,
    super.inputDecorationTheme,
    super.borderRadius,
    super.prefixIcon,
    super.suffixIcon,
    super.autofocus,
    super.minLines = 1,
    super.maxLines,
    super.maxLength,
    super.readOnly,
    super.validator,
    super.onChanged,
    super.isEnabled,
    super.inputFormatters,
    super.keyboardType,
    super.obscureText,
    super.errorText,
    super.errorStyle,
    super.forceErrorText,
    super.hintStyle,
    super.style,
    super.autocorrect,
    super.enableSuggestions,
  }) : super(hintText: hintText?.tr());
}
