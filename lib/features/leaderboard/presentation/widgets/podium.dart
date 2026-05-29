import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/data/models/team_member_progress_model.dart';
import '../../../teams/presentation/widgets/team_disc.dart';

class Podium extends StatelessWidget {
  const Podium({super.key, required this.members});

  final List<TeamMemberProgressModel> members;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final top = members.take(3).toList();

    if (top.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: ResponsiveText(
            'leaderboard.podium_empty',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.oliveSoft,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    _PodiumSeed? seedAt(int i) {
      if (i >= top.length) return null;
      return _PodiumSeed(
        name: top[i].username,
        completed: top[i].completedLevels,
        total: top[i].totalLevels,
      );
    }

    final first = seedAt(0);
    final second = seedAt(1);
    final third = seedAt(2);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumPlace(seed: second, place: 2)),
          const SizedBox(width: 14),
          Expanded(child: _PodiumPlace(seed: first, place: 1, isFirst: true)),
          const SizedBox(width: 14),
          Expanded(child: _PodiumPlace(seed: third, place: 3)),
        ],
      ),
    );
  }
}

class _PodiumSeed {
  const _PodiumSeed({
    required this.name,
    required this.completed,
    required this.total,
  });

  final String name;
  final int completed;
  final int total;
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.seed,
    required this.place,
    this.isFirst = false,
  });

  final _PodiumSeed? seed;
  final int place;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = seed;
    final tone = switch (place) {
      1 => _PodiumTone(
          edge: colors.accentDeep,
          fill: colors.accentDeep.withValues(alpha: 0.32),
          text: colors.accentDeep,
          height: 44,
        ),
      2 => _PodiumTone(
          edge: colors.olive,
          fill: colors.olive.withValues(alpha: 0.18),
          text: colors.olive,
          height: 30,
        ),
      _ => _PodiumTone(
          edge: AppColors.date,
          fill: AppColors.date.withValues(alpha: 0.22),
          text: AppColors.date,
          height: 22,
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFirst && s != null) const _CrownGlyph(),
          _PodiumAvatar(seed: s?.name ?? '?', place: place, isFirst: isFirst),
          const SizedBox(height: 8),
          ResponsiveText(
            s?.name ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: isFirst ? 12 : 11,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
              color: isFirst ? AppColors.dateDeep : colors.oliveDeep,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          ResponsiveText(
            s == null ? '—' : '${s.completed}/${s.total}',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppTextStyles.labelSmall.copyWith(
              fontFamily: 'monospace',
              fontSize: isFirst ? 11 : 10,
              fontWeight: FontWeight.w500,
              color: tone.text,
              letterSpacing: 0.4,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: tone.height,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tone.fill, tone.fill.withValues(alpha: 0.04)],
              ),
              border: Border(
                top: BorderSide(color: tone.edge.withValues(alpha: 0.45)),
                left: BorderSide(color: tone.edge.withValues(alpha: 0.45)),
                right: BorderSide(color: tone.edge.withValues(alpha: 0.45)),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: ResponsiveText(
              '0$place',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                fontFamily: 'monospace',
                fontSize: isFirst ? 12 : 11,
                fontWeight: FontWeight.w700,
                color: tone.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumTone {
  const _PodiumTone({
    required this.edge,
    required this.fill,
    required this.text,
    required this.height,
  });

  final Color edge;
  final Color fill;
  final Color text;
  final double height;
}

class _PodiumAvatar extends StatelessWidget {
  const _PodiumAvatar({
    required this.seed,
    required this.place,
    required this.isFirst,
  });

  final String seed;
  final int place;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final size = isFirst ? 60.0 : 48.0;
    final colors = context.appColors;
    final accent = switch (place) {
      1 => colors.accentDeep,
      2 => colors.oliveSoft,
      _ => AppColors.date,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.45),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          TeamDisc(
            seed: seed,
            size: size,
            fontSize: isFirst ? 22 : 18,
          ),
          Positioned(
            right: -2,
            bottom: -1,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.creamLight,
                border: Border.all(color: accent, width: 1.5),
              ),
              child: ResponsiveText(
                '$place',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrownGlyph extends StatelessWidget {
  const _CrownGlyph();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Icon(
          Icons.workspace_premium_rounded,
          size: 20,
          color: AppColors.amberDeep,
        ),
      );
}
