import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/cubit/teams_state.dart';
import '../../../teams/presentation/widgets/team_scaffold.dart';
import '../widgets/leaderboard_body.dart';
import '../widgets/leaderboard_top_bar.dart';
import '../widgets/timeframe_tabs.dart';

const String _fallbackJoinCode = 'SABR-2419';
const String _myUserId = 'u5';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TeamsCubit>();
      if (cubit.state.team == null) {
        cubit.loadTeamStatus();
      } else {
        if (cubit.state.members == null) cubit.loadTeamMembers();
        if (cubit.state.progress == null) cubit.loadTeamProgress();
      }
      if (cubit.state.leaderboardMembers == null) {
        cubit.loadLeaderboard(cubit.state.leaderboardTimeframe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        final members = state.leaderboardMembers ?? const [];
        final joinCode = state.team?.joinCode ?? _fallbackJoinCode;

        return TeamScaffold(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Column(
                children: [
                  LeaderboardTopBar(
                    teamName: state.team?.name ?? 'Companions of Sabr',
                    joinCode: joinCode,
                  ),
                  const SizedBox(height: 16),
                  TimeframeTabs(
                    value: state.leaderboardTimeframe,
                    onChanged: (t) =>
                        context.read<TeamsCubit>().loadLeaderboard(t),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: LeaderboardBody(
                      status: state.leaderboardStatus,
                      members: members,
                      myUserId: _myUserId,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
