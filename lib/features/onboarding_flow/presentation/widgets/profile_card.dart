import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/profile_entity.dart';
import 'child_avatar_circle.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.entry, required this.onTap});

  final ProfileEntity entry;
  final VoidCallback onTap;

  static const _avatarOuter = 96.0;
  static const _avatarInner = 84.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ProfileTileShell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (entry.isParent) const _ParentBadge(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(entry: entry, colors: colors),
              const SizedBox(height: 12),
              ResponsiveText(
                entry.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                  color: colors.oliveDeep,
                ),
              ),
              const SizedBox(height: 4),
              _RoleLabel(entry: entry, colors: colors),
              const SizedBox(height: 8),
              _BottomChip(entry: entry, colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared frame for tiles in the profile picker grid (parent/child cards and
/// the add-child tile). Owns the rounded background, border, padding, and ink
/// response so all tiles stay visually coherent.
class ProfileTileShell extends StatelessWidget {
  const ProfileTileShell({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  static final BorderRadius _radius = BorderRadius.circular(ZaadRadii.xxl);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: _radius,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: _radius,
            border: Border.all(
              color: colors.oliveSoft.withValues(alpha: 0.20),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ParentBadge extends StatelessWidget {
  const _ParentBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned(
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
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry, required this.colors});

  final ProfileEntity entry;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    final showRing = !entry.isParent && entry.progress != null;
    return SizedBox.square(
      dimension: ProfileCard._avatarOuter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showRing)
            CustomPaint(
              size: const Size.square(ProfileCard._avatarOuter),
              painter: _ProgressRingPainter(
                progress: entry.progress!,
                track: colors.oliveSoft.withValues(alpha: 0.18),
                fill: colors.accent,
              ),
            ),
          Container(
            width: ProfileCard._avatarInner,
            height: ProfileCard._avatarInner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: entry.isParent
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.oliveSoft, colors.oliveDeep],
                    )
                  : null,
              border: Border.all(
                color: colors.oliveSoft.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: entry.isParent
                ? const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: AppColors.ivory,
                  )
                : ChildAvatarCircle(
                    avatar: entry.avatar!,
                    size: ProfileCard._avatarInner,
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoleLabel extends StatelessWidget {
  const _RoleLabel({required this.entry, required this.colors});

  final ProfileEntity entry;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 1.8,
      color: entry.isParent ? AppColors.date : colors.oliveSoft,
    );

    if (entry.isParent) {
      return ResponsiveText(
        'profile_select.role_parent',
        textAlign: TextAlign.center,
        style: style,
      );
    }
    if (entry.age == null) return const SizedBox.shrink();
    return ResponsiveText(
      'profile_select.age_label'.tr(args: ['${entry.age}']).toUpperCase(),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

class _BottomChip extends StatelessWidget {
  const _BottomChip({required this.entry, required this.colors});

  final ProfileEntity entry;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    if (entry.isParent) {
      return _CurrentAccountTag(colors: colors);
    }
    if (entry.streak != null) {
      return _StreakChip(streak: entry.streak!, colors: colors);
    }
    // Reserve the chip slot height so every card aligns vertically.
    return const SizedBox(height: 22);
  }
}

class _CurrentAccountTag extends StatelessWidget {
  const _CurrentAccountTag({required this.colors});

  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.oliveSoft.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.oliveSoft.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: colors.oliveDeep,
          ),
          const SizedBox(width: 5),
          ResponsiveText(
            'profile_select.current_account',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak, required this.colors});

  final int streak;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 11,
            color: colors.accent,
          ),
          const SizedBox(width: 5),
          ResponsiveText(
            '$streak ${'profile_select.days'.tr()}',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.accentDeep,
            ),
          ),
        ],
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
