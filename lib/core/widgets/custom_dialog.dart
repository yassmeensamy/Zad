import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    this.radius = 28,
    this.constraints,
    this.insetPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final BoxConstraints? constraints;
  final EdgeInsets? insetPadding;

  static const double _borderStroke = 1.6;
  static const LinearGradient _borderGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    stops: [0.4, 0.9],
    colors: [AppColors.creamBorderDark, AppColors.creamBorderLight],
  );

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    double radius = 28,
    BoxConstraints? constraints,
    EdgeInsets? insetPadding,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => CustomDialog(
        padding: padding,
        radius: radius,
        constraints: constraints,
        insetPadding: insetPadding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: insetPadding ??
          EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.07,
          ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          constraints: constraints,
          padding: const EdgeInsets.all(_borderStroke),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: _borderGradient,
            boxShadow: [
              BoxShadow(
                color: colors.textArabic.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius - _borderStroke),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.canvas, colors.canvasRaised],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
