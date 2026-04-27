import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/custom_button_theme.dart';
import 'responsive_text.dart';

/// Button size presets
enum CustomButtonSize {
  /// Width determined by the child.
  intrinsic,

  /// Stretches to fill the available width.
  full,
}

class CustomButton extends StatefulWidget {
  /// Default: button hugs its child.
  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onTap,
    this.enabled = true,
    this.loading = false,
    this.theme,
  }) : size = CustomButtonSize.intrinsic;

  /// Button that stretches to fill available width.
  const CustomButton.full({
    super.key,
    this.text,
    this.child,
    this.onTap,
    this.enabled = true,
    this.loading = false,
    this.theme,
  }) : size = CustomButtonSize.full;

  final String? text;
  final Widget? child;
  final FutureOr<void> Function()? onTap;
  final bool enabled;
  final bool loading;
  final CustomButtonTheme? theme;
  final CustomButtonSize size;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme =
        widget.theme ?? Theme.of(context).extension<CustomButtonTheme>()!;
    final width = switch (widget.size) {
      CustomButtonSize.intrinsic => null,
      CustomButtonSize.full => double.infinity,
    };

    final textStyle = _resolveTextStyle(context, theme);
    final indicatorColor = theme.textColor ?? textStyle?.color ?? Colors.white;

    final content = _isLoading
        ? (theme.loadingWidget ??
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: indicatorColor,
                ),
              ))
        : (widget.child ??
              ResponsiveText(
                widget.text ?? 'Button',
                textAlign: TextAlign.center,
                style: textStyle,
              ));

    return Padding(
      padding: theme.margin ?? EdgeInsets.zero,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.6,
        child: GestureDetector(
          onTap: widget.enabled ? _handleTap : null,
          child: Container(
            width: width,
            height: theme.height,
            padding: theme.padding,
            decoration: BoxDecoration(
              color: theme.useGradient ? null : theme.backgroundColor,
              gradient: theme.useGradient ? theme.gradient : null,
              borderRadius: BorderRadius.circular(theme.borderRadius),
              border: theme.borderColor != null
                  ? Border.all(color: theme.borderColor!)
                  : null,
            ),
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: content),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle? _resolveTextStyle(BuildContext context, CustomButtonTheme theme) {
    final base = theme.textStyle ?? Theme.of(context).textTheme.bodySmall;
    if (theme.textColor == null) return base;
    return (base ?? const TextStyle()).copyWith(color: theme.textColor);
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    final result = widget.onTap!();
    if (result is! Future) return;
    setState(() => _isLoading = true);
    result.whenComplete(() {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }
}
