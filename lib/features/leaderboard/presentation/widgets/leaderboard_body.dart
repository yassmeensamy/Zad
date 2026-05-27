import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../teams/data/models/team_member_progress_model.dart';
import '../../../teams/presentation/cubit/teams_state.dart';
import 'all_members_header.dart';
import 'climbing_list.dart';
import 'podium.dart';
import 'top_three_eyebrow.dart';

class LeaderboardBody extends StatelessWidget {
  const LeaderboardBody({
    super.key,
    required this.status,
    required this.members,
    required this.myUserId,
  });

  final LeaderboardStatus status;
  final List<TeamMemberProgressModel> members;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (status == LeaderboardStatus.loading && members.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.oliveDeep,
          strokeWidth: 2,
        ),
      );
    }
    if (status == LeaderboardStatus.error && members.isEmpty) {
      return Center(
        child: Text(
          "Couldn't load the leaderboard.",
          style: TextStyle(
            fontSize: 12,
            color: colors.oliveSoft,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TopThreeEyebrow(),
        const SizedBox(height: 8),
        Podium(members: members),
        const SizedBox(height: 14),
        AllMembersHeader(count: members.length),
        const SizedBox(height: 8),
        ClimbingList(members: members, myUserId: myUserId),
      ],
    );
  }
}
