import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/l10n/app_languages.dart';

class MainTextFormField extends StatefulWidget {
  const MainTextFormField({
    super.key,

    this.controller,
    this.initialValue,
    this.onChanged,
    this.focusNode,
    this.inputDecorationTheme,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.textInputAction,
    this.style,
    this.isEnabled = true,
    this.autofocus = false,
    this.maxLines,
    this.minLines = 1,
    this.hintText,
    this.obscureText = false,
    this.passwordToggle = false,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
    this.prefixIcon,
    this.autofillHints,
    this.contentPadding,
    this.iconSize,
    this.hintStyle,
    this.onFieldSubmitted,
    this.borderRadius,
    this.counterText,
    this.errorText,
  });

  // Core
  final TextEditingController? controller;
  final String? initialValue;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool isEnabled;
  final int? maxLines;
  final int minLines;
  final int? maxLength;
  final bool obscureText;
  final bool passwordToggle;
  final String? counterText;

  // Validation
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;

  final InputDecorationThemeData? inputDecorationTheme;
  final String? hintText;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final double? iconSize;
  final BorderRadius? borderRadius;

  // Layout & style
  final TextStyle? style;
  // Autofill
  final List<String>? autofillHints;

  @override
  State<MainTextFormField> createState() => _MainTextFormFieldState();
}

class _MainTextFormFieldState extends State<MainTextFormField> {
  late final TextEditingController _controller;
  late bool _obscureText;
  final ValueNotifier<TextDirection> _textDirection =
      ValueNotifier<TextDirection>(TextDirection.ltr);
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;

    _controllerListener = () {
      _textDirection.value = _getTextDirection(_controller.text);
      widget.onChanged?.call(_controller.text);
    };
    _controller.addListener(_controllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to read EasyLocalization/Theme/etc.
    _textDirection.value = _getTextDirection(_controller.text);
  }

  @override
  void didUpdateWidget(MainTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the field has no built-in toggle, let an externally-controlled
    // [obscureText] drive the obscure state (e.g. a parent-owned eye button).
    if (!widget.passwordToggle && widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    if (widget.controller == null) _controller.dispose();
    _textDirection.dispose();
    super.dispose();
  }

  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) {
      return context.appLanguage.isRtl
          ? TextDirection.rtl
          : TextDirection.ltr;
    }

    final rtlRegex = RegExp(
      r'[֐-׿؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]',
    );
    return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  Widget? _buildSuffixIcon() {
    if (!widget.passwordToggle) return null;
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        size: widget.iconSize ?? 24,
      ),
      onPressed: () => setState(() => _obscureText = !_obscureText),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final theme =
        widget.inputDecorationTheme ?? Theme.of(context).inputDecorationTheme;

    InputDecoration deco = const InputDecoration().applyDefaults(theme);

    deco = deco.copyWith(
      hintText: widget.hintText ?? deco.hintText,
      prefixIcon: widget.prefixIcon ?? deco.prefixIcon,
      suffixIcon: _buildSuffixIcon() ?? deco.suffixIcon,
      contentPadding: widget.contentPadding ?? deco.contentPadding,
      hintStyle: widget.hintStyle ?? deco.hintStyle,
      counterText: widget.counterText ?? deco.counterText,
      errorText: widget.errorText,
    );

    if (widget.borderRadius != null) {
      InputBorder? withRadius(InputBorder? b) {
        if (b is OutlineInputBorder) {
          return b.copyWith(borderRadius: widget.borderRadius!);
        }
        return OutlineInputBorder(borderRadius: widget.borderRadius!);
      }

      deco = deco.copyWith(
        border: withRadius(deco.border),
        enabledBorder: withRadius(deco.enabledBorder),
        focusedBorder: withRadius(deco.focusedBorder),
        disabledBorder: withRadius(deco.disabledBorder),
        errorBorder: withRadius(deco.errorBorder),
        focusedErrorBorder: withRadius(deco.focusedErrorBorder),
      );
    }

    return deco;
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = _buildDecoration(context);
    return ValueListenableBuilder<TextDirection>(
      valueListenable: _textDirection,
      builder: (context, direction, _) {
        return TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          decoration: inputDecoration,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
          textDirection: direction,
          autofocus: widget.autofocus,
          enabled: widget.isEnabled,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: _obscureText ? 1 : widget.minLines,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          cursorColor: inputDecoration.focusColor,
        );
      },
    );
  }
}
