import 'package:flutter/material.dart';

import '../../../../core/utils/name_display.dart';
import '../../../../core/utils/number_format.dart';
import '../../../../core/widgets/podium_row.dart';
import 'leaderboard_states.dart';
import 'rank_seed.dart';

/// The leaderboard's top three, mapped onto the shared [PodiumRow].
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
    PodiumEntry? at(int i) =>
        i < seeds.length ? _entry(context, seeds[i]) : null;
    return PodiumRow(places: [at(0), at(1), at(2)]);
  }

  PodiumEntry _entry(BuildContext context, RankSeed seed) {
    final points = seed.points;
    return PodiumEntry(
      initial: initialOf(seed.name),
      name: seed.name,
      caption: '${seed.completed}/${seed.total}',
      flag: seed.flag,
      // Points sit under the level count — individuals only; the teams podium
      // has no points to show.
      noteIcon: points == null ? null : Icons.stars_rounded,
      note: points == null ? null : groupedNumber(context, points),
    );
  }
}
