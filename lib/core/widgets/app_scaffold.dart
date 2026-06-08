import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'app_backdrop.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar,
    this.resizeToAvoidBottomInset,
    this.safeArea = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool? extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = safeArea ? SafeArea(bottom: false, child: body) : body;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: isDark ? const AppBackdrop() : const _LightBackdrop(),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar ?? false,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          body: content,
        ),
      ],
    );
  }
}

class _LightBackdrop extends StatelessWidget {
  const _LightBackdrop();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.backdropTop, colors.backdropBottom],
        ),
      ),
    );
  }
}
