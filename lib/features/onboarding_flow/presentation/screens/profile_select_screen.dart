import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../data/child_avatar.dart';
import '../widgets/child_avatar_circle.dart';
import '../widgets/onboarding_topnav.dart';

class _ProfileEntry {
  const _ProfileEntry.parent({required this.name})
      : isParent = true,
        avatar = null,
        age = null,
        progress = null,
        streak = null;

  const _ProfileEntry.child({
    required this.name,
    required this.age,
    required this.avatar,
    required this.progress,
    required this.streak,
  }) : isParent = false;

  final bool isParent;
  final String name;
  final int? age;
  final ChildAvatar? avatar;
  final double? progress;
  final int? streak;
}

class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  static final _profiles = <_ProfileEntry>[
    const _ProfileEntry.parent(name: 'Ahmad'),
    _ProfileEntry.child(
      name: 'Yusuf',
      age: 7,
      avatar: ChildAvatar.palm,
      progress: 0.7,
      streak: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: DesertBackground(
        child: SafeArea(
          child: Column(
            children: [
              const OnboardingTopNav(showBrand: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
                  child: Column(
                    children: [
                      _Heading(colors: colors),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _profiles.length + 1,
                          itemBuilder: (_, i) {
                            if (i == _profiles.length) {
                              return _AddTile(
                                onTap: () =>
                                    context.go(AppRoutes.createProfiles),
                              );
                            }
                            final p = _profiles[i];
                            return _ProfileCard(
                              entry: p,
                              onTap: () => context.go(AppRoutes.home),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings_rounded,
                              size: 14,
                              color: colors.oliveSoft,
                            ),
                            const SizedBox(width: 6),
                            ResponsiveText(
                              'profile_select.manage',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.dateSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: GoogleFonts.amiri(
                            fontSize: 13,
                            color: colors.oliveDeep.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveText(
          'profile_select.eyebrow'.tr().toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 10 * 0.32,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: GoogleFonts.fraunces(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              height: 1.15,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'profile_select.title_prefix'.tr()),
              TextSpan(
                text: 'profile_select.title_accent'.tr(),
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.textArabic,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'profile_select.subtitle',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.entry, required this.onTap});
  final _ProfileEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.oliveSoft.withValues(alpha: 0.20), width: 1.5),
          ),
          child: Stack(
            children: [
              if (entry.isParent)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accent.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 13,
                      color: colors.accentDeep,
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!entry.isParent && entry.progress != null)
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: CustomPaint(
                              painter: _ProgressRingPainter(
                                progress: entry.progress!,
                                track:
                                    colors.oliveSoft.withValues(alpha: 0.18),
                                fill: colors.accent,
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.oliveSoft.withValues(alpha: 0.22),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: entry.isParent
                                ? Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colors.oliveSoft,
                                          colors.oliveDeep,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: AppColors.ivory,
                                    ),
                                  )
                                : ChildAvatarCircle(
                                    avatar: entry.avatar!,
                                    size: 84,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ResponsiveText(
                    entry.name,
                    style: GoogleFonts.fraunces(
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      color: colors.oliveDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText(
                    entry.isParent
                        ? 'profile_select.role_parent'.tr().toUpperCase()
                        : 'profile_select.age_label'
                            .tr(args: ['${entry.age}']).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 10 * 0.18,
                      color: entry.isParent
                          ? AppColors.date
                          : colors.oliveSoft,
                    ),
                  ),
                  if (!entry.isParent && entry.streak != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 11,
                            color: colors.accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${entry.streak} ${'profile_select.days'.tr()}',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: colors.accentDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.oliveSoft.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.6),
                  border: Border.all(
                    color: colors.oliveSoft.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(Icons.add_rounded, size: 22, color: colors.olive),
              ),
              const SizedBox(height: 14),
              ResponsiveText(
                'profile_select.add_child',
                style: GoogleFonts.fraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  color: colors.olive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - 4) / 2;
    final center = size.center(Offset.zero);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = track;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = fill
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}
