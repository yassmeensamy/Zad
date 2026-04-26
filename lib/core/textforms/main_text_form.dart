import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.isEnabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines,
    this.minLines = 1,
    this.hintText,
    this.obscureText = false,
    this.passwordToggle = false,
    this.maxLength,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.onTap,
    this.contentPadding,
    this.iconSize,
    this.hintStyle,
    this.labelStyle,
    this.onFieldSubmitted,
    this.prefixText,
    this.showClearButton = false,
    this.borderRadius,
    this.counterText,
    this.textDirection,
    this.errorText,
    this.errorStyle,
    this.forceErrorText,
    this.autocorrect = true,
    this.enableSuggestions = true,
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
  final bool readOnly;
  final bool isEnabled;
  final int? maxLines;
  final int minLines;
  final int? maxLength;
  final bool obscureText;
  final bool passwordToggle;
  final String? counterText;
  final bool autocorrect;
  final bool enableSuggestions;

  // Validation
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;
  final TextStyle? errorStyle;
  final String? forceErrorText;

  final InputDecorationThemeData? inputDecorationTheme;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final double? iconSize;
  final BorderRadius? borderRadius;
  final bool showClearButton;

  // Layout & style
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  // Autofill
  final List<String>? autofillHints;

  // Gestures
  final VoidCallback? onTap;

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
  void dispose() {
    _controller.removeListener(_controllerListener);
    if (widget.controller == null) _controller.dispose();
    _textDirection.dispose();
    super.dispose();
  }

  TextDirection _getTextDirection(String text) {
    if (widget.textDirection != null) {
      return widget.textDirection!;
    }
    if (text.isEmpty) {
      return context.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr;
    }

    final rtlRegex = RegExp(
      r'[֐-׿؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]',
    );
    return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  Widget? _buildSuffixIcon() {
    final widgets = <Widget>[];

    if (widget.passwordToggle) {
      widgets.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: widget.iconSize ?? 24,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );
    }

    if (widget.showClearButton) {
      widgets.add(
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, __, ___) {
            if (_controller.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.clear, size: widget.iconSize ?? 24),
              onPressed: () => _controller.clear(),
            );
          },
        ),
      );
    }

    if (widget.suffixIcon != null && widgets.isEmpty) {
      widgets.add(widget.suffixIcon!);
    }

    if (widgets.isEmpty) return null;
    if (widgets.length == 1) return widgets.first;
    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final theme =
        widget.inputDecorationTheme ?? Theme.of(context).inputDecorationTheme;

    InputDecoration deco = const InputDecoration().applyDefaults(theme);

    deco = deco.copyWith(
      hintText: widget.hintText ?? deco.hintText,
      prefixIcon: widget.prefixIcon ?? deco.prefixIcon,
      suffixIcon: _buildSuffixIcon() ?? deco.suffixIcon,
      prefixText: widget.prefixText ?? deco.prefixText,
      contentPadding: widget.contentPadding ?? deco.contentPadding,
      hintStyle: widget.hintStyle ?? deco.hintStyle,
      labelStyle: widget.labelStyle ?? deco.labelStyle,
      counterText: widget.counterText ?? deco.counterText,
      errorText: widget.errorText,
      errorStyle: widget.errorStyle ?? deco.errorStyle,
      error:
          widget.forceErrorText != null
              ? Text(
                widget.forceErrorText!,
                style: widget.errorStyle ?? deco.errorStyle,
              )
              : null,
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
    final effectiveInitialValue =
        widget.controller == null ? widget.initialValue : null;
    final inputDecoration = _buildDecoration(context);
    return ValueListenableBuilder<TextDirection>(
      valueListenable: _textDirection,
      builder: (context, direction, _) {
        return TextFormField(
          controller: _controller,
          initialValue: effectiveInitialValue,
          focusNode: widget.focusNode,
          decoration: inputDecoration,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          style: widget.style ?? Theme.of(context).textTheme.bodyLarge,

          strutStyle: widget.strutStyle,
          textDirection: direction,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.isEnabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onFieldSubmitted,
          cursorColor: inputDecoration.focusColor,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
        );
      },
    );
  }
}
