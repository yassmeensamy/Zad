import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../theme/theme.dart';

/// Warm gold shimmer tuned for the leaderboard skeletons.
ShimmerEffect _leaderboardShimmer(BuildContext context) {
  final colors = context.appColors;
  return ShimmerEffect(
    baseColor: colors.accent.withValues(alpha: 0.10),
    highlightColor: colors.accentSoft.withValues(alpha: 0.22),
  );
}

/// Full-screen skeleton shown while the first page of rankings loads. Mirrors
/// the real body layout (podium trio + ranking rows) so the swap to live data
/// produces no layout shift or jarring spinner.
class LeaderboardLoading extends StatelessWidget {
  const LeaderboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      effect: _leaderboardShimmer(context),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 2),
          const Center(child: Bone.text(width: 64, fontSize: 9)),
          const SizedBox(height: 14),
          const _SkeletonPodium(),
          const SizedBox(height: 18),
          const Center(child: Bone.text(width: 132, fontSize: 9)),
          const SizedBox(height: 12),
          for (var i = 0; i < 6; i++) ...[
            const _SkeletonRow(),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// A short strip of skeleton rows for the pagination ("load more") footer.
class LeaderboardMoreLoading extends StatelessWidget {
  const LeaderboardMoreLoading({super.key, this.count = 2});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      effect: _leaderboardShimmer(context),
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            const _SkeletonRow(),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _SkeletonPodium extends StatelessWidget {
  const _SkeletonPodium();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 100, child: _PodiumPlace(avatar: 52, pedestal: 34)),
          SizedBox(width: 9),
          Expanded(flex: 115, child: _PodiumPlace(avatar: 62, pedestal: 46)),
          SizedBox(width: 9),
          Expanded(flex: 100, child: _PodiumPlace(avatar: 52, pedestal: 25)),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.avatar, required this.pedestal});

  final double avatar;
  final double pedestal;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Bone.circle(size: avatar),
        const SizedBox(height: 9),
        const Bone.text(width: 44, fontSize: 11),
        const SizedBox(height: 6),
        const Bone.text(width: 30, fontSize: 10),
        const SizedBox(height: 8),
        Bone(
          width: double.infinity,
          height: pedestal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
        ),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colors.textPrimary.withValues(alpha: 0.024),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.05)),
      ),
      child: const Row(
        children: [
          Bone.text(width: 16, fontSize: 12),
          SizedBox(width: 12),
          Bone.circle(size: 38),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 110, fontSize: 13.5),
                SizedBox(height: 6),
                Bone.text(width: 70, fontSize: 10),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Bone.text(width: 34, fontSize: 14),
              SizedBox(height: 4),
              Bone.text(width: 24, fontSize: 10.5),
            ],
          ),
        ],
      ),
    );
  }
}
