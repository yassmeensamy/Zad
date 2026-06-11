import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_dialog.dart';
import '../cubit/teams_cubit.dart';
import 'create_team_dialog.dart';

/// Centered popup that collects only the team name and submits.
/// Returns `true` when the team was created successfully so the caller
/// can route into the team flow.
Future<bool> showCreateTeamSheet(BuildContext context) async {
  final cubit = context.read<TeamsCubit>();
  cubit.resetCreateState();

  final result = await CustomDialog.show<bool>(
    context: context,
    barrierDismissible: false,
    radius: 24,
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
    child: BlocProvider<TeamsCubit>.value(
      value: cubit,
      child: const CreateTeamDialog(),
    ),
  );
  return result ?? false;
}
