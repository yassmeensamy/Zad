import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/widgets/responsive_text.dart';
import '../../theme/theme.dart';
import 'widgets/desert_background.dart';
import 'widgets/zaad_brand.dart';
import 'widgets/zaad_logo_mark.dart';

class ZaadSplashScreen extends StatefulWidget {
  const ZaadSplashScreen({super.key});

  @override
  State<ZaadSplashScreen> createState() => _ZaadSplashScreenState();
}

class _ZaadSplashScreenState extends State<ZaadSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final AnimationController _hintPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) _hintPulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _hintPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: DesertBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZaadLogoMark(animation: _intro),
                        const SizedBox(height: 32),
                        _StaggeredFade(
                          controller: _intro,
                          start: 0.42,
                          end: 0.6,
                          child: const ZaadBrand(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: _StaggeredFade(
                    controller: _intro,
                    start: 0.78,
                    end: 1,
                    targetOpacity: 0.65,
                    child: ResponsiveText(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.textArabic,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_intro, _hintPulse]),
                    builder: (context, _) {
                      final introT =
                          ((_intro.value - 0.9) / 0.1).clamp(0.0, 1.0);
                      final pulse = 0.4 + 0.4 * _hintPulse.value;
                      final opacity = introT * (introT < 1 ? 0.55 : pulse);
                      return Opacity(
                        opacity: opacity,
                        child: ResponsiveText(
                          'LOADING...',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            color: colors.textArabic,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  const _StaggeredFade({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.targetOpacity = 1,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double targetOpacity;
  static const double _translateY = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final raw = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
        final eased = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: eased * targetOpacity,
          child: Transform.translate(
            offset: Offset(0, _translateY * (1 - eased)),
            child: child,
          ),
        );
      },
    );
  }
}
