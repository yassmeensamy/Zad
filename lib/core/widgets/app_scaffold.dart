import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/offline/presentation/cubit/connectivity_cubit.dart';
import '../../theme/theme.dart';
import 'app_backdrop.dart';
import 'responsive_text.dart';

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
    final wrappedBody = Column(
      children: [
        const _OfflineBanner(),
        Expanded(child: body),
      ],
    );
    final content = safeArea
        ? SafeArea(bottom: false, child: wrappedBody)
        : wrappedBody;

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

/// Thin, global "you're offline" indicator shown above any [AppScaffold] body
/// while the device is offline. Reads [ConnectivityCubit] provided at app root.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        if (isOnline) return const SizedBox.shrink();
        final colors = context.appColors;
        return Material(
          color: colors.oliveDeep.withValues(alpha: 0.92),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 15,
                    color: colors.canvas,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ResponsiveText(
                      'offline.banner_message',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.canvas,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
