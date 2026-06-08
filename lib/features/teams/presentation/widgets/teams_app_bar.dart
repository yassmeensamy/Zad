import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../cubit/teams_state.dart';
import 'team_leave_sheet.dart';

/// The one app bar for the whole Teams entry flow. Rendered once, above the
/// body, so it stays fixed in place while the body swaps between the loading,
/// home, empty and error states. Title/subtitle and the leave action adapt to
/// [state]; the bar itself never remounts.
class TeamsAppBar extends StatelessWidget {
  const TeamsAppBar({super.key, required this.state});

  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final team = state.team;
    final hasTeam = state.hasTeam && team != null;

    return ZaadAppBar(
      // ResponsiveText runs `.tr()`; `team.name` is raw and passes through,
      // the others are translation keys.
      title: hasTeam ? team.name : 'teams.empty.title',
      subtitle: hasTeam ? 'teams.home.eyebrow' : 'teams.empty.eyebrow',
      onBack: () => context.canPop()
          ? context.pop()
          : context.goNamed(AppRoutes.homeName),
      action: hasTeam
          ? ZaadCircleIconButton(
              icon: Icons.more_horiz_rounded,
              onTap: () async {
                final left = await showTeamLeaveSheet(context);
                if (left && context.mounted) {
                  context.goNamed(AppRoutes.homeName);
                }
              },
            )
          : null,
    );
  }
}
