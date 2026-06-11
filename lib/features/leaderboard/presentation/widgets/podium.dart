import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'leaderboard_disc.dart';
import 'leaderboard_states.dart';
import 'rank_seed.dart';

/// Top-three podium: silver (2nd) — gold (1st, raised) — bronze (3rd).
class Podium extends StatelessWidget {
  const Podium({super.key, required this.seeds});

  final List<RankSeed> seeds;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) {
      return const LeaderboardEmptyHint(
        textKey: 'leaderboard.podium_empty',
        vertical: 28,
      );
    }
    RankSeed? at(int i) => i < seeds.length ? seeds[i] : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 100, child: _PodiumPillar(place: 2, seed: at(1))),
          const SizedBox(width: 9),
          Expanded(flex: 115, child: _PodiumPillar(place: 1, seed: at(0))),
          const SizedBox(width: 9),
          Expanded(flex: 100, child: _PodiumPillar(place: 3, seed: at(2))),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({required this.place, required this.seed});

  final int place;
  final RankSeed? seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isFirst = place == 1;
    final accent = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.emberBright,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    final pedTint = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.ember,
    };
    final avatarSize = isFirst ? 62.0 : 52.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: avatarSize + 14,
          height: avatarSize + (isFirst ? 22 : 14),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize + 14,
                height: avatarSize + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.5),
                      accent.withValues(alpha: 0),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              LeaderboardDisc(
                size: avatarSize,
                initial: discInitial(seed?.name),
                style: discStyleForPlace(place),
                fontSize: isFirst ? 24 : 20,
              ),
              if (isFirst && seed != null)
                const Positioned(top: -8, child: _Crown()),
              Positioned(
                right: 2,
                bottom: 2,
                child: _RankBadge(place: place, color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        ResponsiveText(
          seed?.name ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? colors.accent : colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          seed == null ? '—' : '${seed!.completed}/${seed!.total}',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: accent,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: pedHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(
              top: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              left: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              right: BorderSide(color: pedTint.withValues(alpha: 0.4)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                pedTint.withValues(alpha: 0.28),
                pedTint.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: ResponsiveText(
            place < 10 ? '0$place' : '$place',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.place, required this.color});

  final int place;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.canvas,
        border: Border.all(color: color, width: 2),
      ),
      child: ResponsiveText(
        '$place',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 16,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 26;
    final sy = size.height / 16;
    final path = Path()
      ..moveTo(1.5 * sx, 14 * sy)
      ..lineTo(4 * sx, 5 * sy)
      ..lineTo(9.5 * sx, 10.5 * sy)
      ..lineTo(13 * sx, 2.5 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(22 * sx, 5 * sy)
      ..lineTo(24.5 * sx, 14 * sy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.discGoldHi, AppColors.discGoldLo],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.discBronzeLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
