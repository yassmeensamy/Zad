import 'dart:ui';

import 'package:flutter/material.dart';

class CustomButtonTheme extends ThemeExtension<CustomButtonTheme> {
  const CustomButtonTheme({
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.margin,
    this.borderRadius = 30,
    this.useGradient = false,
    this.gradient,
    this.backgroundColor = const Color(0xFF424BB3),
    this.textColor = Colors.white,
    this.borderColor,
    this.loadingWidget,
    this.textStyle,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool useGradient;
  final Gradient? gradient;
  final Color backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? loadingWidget;
  final TextStyle? textStyle;

  @override
  CustomButtonTheme copyWith({
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    bool? useGradient,
    Gradient? gradient,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    Widget? loadingWidget,
    TextStyle? textStyle,
  }) {
    return CustomButtonTheme(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      useGradient: useGradient ?? this.useGradient,
      gradient: gradient ?? this.gradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  CustomButtonTheme lerp(ThemeExtension<CustomButtonTheme>? other, double t) {
    if (other is! CustomButtonTheme) {
      return this;
    }
    return CustomButtonTheme(
      width: lerpDouble(width, other.width, t) ?? width,
      height: lerpDouble(height, other.height, t),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t) ?? padding,
      margin: EdgeInsetsGeometry.lerp(margin, other.margin, t),
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      useGradient: t < 0.5 ? useGradient : other.useGradient,
      gradient: t < 0.5 ? gradient : other.gradient,
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      textColor: Color.lerp(textColor, other.textColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      loadingWidget: t < 0.5 ? loadingWidget : other.loadingWidget,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
