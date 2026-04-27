import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/onboarding_model.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>()..load(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<OnboardingCubit, OnboardingState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) return _ErrorView(onRetry: context.read<OnboardingCubit>().load);
          return _PagesView(controller: _pageController, pages: state.pages);
        },
      ),
    );
  }
}

class _PagesView extends StatelessWidget {
  const _PagesView({required this.controller, required this.pages});

  final PageController controller;
  final List<OnboardingModel> pages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          itemCount: pages.length,
          onPageChanged: context.read<OnboardingCubit>().changePage,
          itemBuilder: (_, i) => _Page(model: pages[i]),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: _BottomBar(
              pageCount: pages.length,
              onNext: () => _onPrimaryTap(context),
            ),
          ),
        ),
      ],
    );
  }

  void _onPrimaryTap(BuildContext context) {
    final state = context.read<OnboardingCubit>().state;
    final isLast = state.currentPage >= pages.length - 1;
    if (isLast) {
      context.read<OnboardingCubit>().setFirstOpen();
      context.go(AppRoutes.login);
    } else {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.model});

  final OnboardingModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          model.image,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, p) => p == null
              ? child
              : Container(color: context.appColors.canvasRaised),
          errorBuilder: (_, _, _) =>
              Container(color: context.appColors.canvasRaised),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
              ],
              stops: const [0.5, 1],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 200),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  model.text,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  model.subText,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.pageCount, required this.onNext});

  final int pageCount;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OnboardingCubit, OnboardingState, int>(
      selector: (s) => s.currentPage,
      builder: (context, current) {
        final isLast = current >= pageCount - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Indicators(count: pageCount, current: current),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNext,
                child: ResponsiveText(isLast ? 'Get started' : 'Next'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Indicators extends StatelessWidget {
  const _Indicators({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: active ? primary : primary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ResponsiveText('Failed to load onboarding'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const ResponsiveText('Retry')),
        ],
      ),
    );
  }
}
