import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/navigation/app_routes.dart';
import '../../theme/theme.dart';
import 'widgets/desert_background.dart';
import 'widgets/zad_brand.dart';
import 'widgets/zad_logo_mark.dart';

class ZadSplashScreen extends StatefulWidget {
  const ZadSplashScreen({super.key});

  @override
  State<ZadSplashScreen> createState() => _ZadSplashScreenState();
}

class _ZadSplashScreenState extends State<ZadSplashScreen>
    with TickerProviderStateMixin {
  static const _dateSoft = Color(0xFF8D5C36);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final AnimationController _hintPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  Timer? _autoAdvance;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _autoAdvance = Timer(const Duration(milliseconds: 4500), _goToLogin);
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) _hintPulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _intro.dispose();
    _hintPulse.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (_navigating || !mounted) return;
    _navigating = true;
    _autoAdvance?.cancel();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToLogin,
        child: DesertBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // Center column: mark + brand.
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZadLogoMark(animation: _intro),
                        const SizedBox(height: 32),
                        _StaggeredFade(
                          controller: _intro,
                          start: 0.42,
                          end: 0.6,
                          child: ZadBrand(dateSoft: _dateSoft),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bismillah, near the bottom.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: _StaggeredFade(
                    controller: _intro,
                    start: 0.78,
                    end: 1,
                    targetOpacity: 0.65,
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: colors.textArabic,
                      ),
                    ),
                  ),
                ),
                // "Tap to begin" hint.
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
                        child: Text(
                          'TAP TO BEGIN',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
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
      ),
    );
  }
}

/// Drives a child between opacity 0 (with a small upward translation) and
/// [targetOpacity] across [start]..[end] of the supplied controller's value.
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
