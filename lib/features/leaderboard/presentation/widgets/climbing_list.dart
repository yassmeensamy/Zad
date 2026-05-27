import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../teams/data/models/team_member_progress_model.dart';
import 'climb_tile.dart';

class ClimbingList extends StatelessWidget {
  const ClimbingList({
    super.key,
    required this.members,
    required this.myUserId,
  });

  final List<TeamMemberProgressModel> members;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No members to rank yet.',
            style: TextStyle(
              fontSize: 12,
              color: colors.oliveSoft,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < members.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          ClimbTile(
            rank: i + 1,
            member: members[i],
            isMe: members[i].userId == myUserId,
          ),
        ],
      ],
    );
  }
}
