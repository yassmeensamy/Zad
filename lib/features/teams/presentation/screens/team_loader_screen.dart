import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/loader_ring.dart';
import '../widgets/team_scaffold.dart';

/// Entry point for the Teams flow. Calls `getMyTeam()` (via cubit's
/// [TeamsCubit.loadTeamStatus]), holds a min 400 ms parchment loader, then
/// routes to `team_home` or `team_empty`.
class TeamLoaderScreen extends StatefulWidget {
  const TeamLoaderScreen({super.key});

  @override
  State<TeamLoaderScreen> createState() => _TeamLoaderScreenState();
}

class _TeamLoaderScreenState extends State<TeamLoaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<TeamsCubit>();
      final state = cubit.state;

      // Already resolved (e.g. arriving here after a successful create from
      // the bottom sheet) — let the listener route on the next frame.
      if (state.hasTeam || state.hasNoTeam) {
        _route(context, state);
        return;
      }
      // Already in-flight from a prior mount — wait for it to land.
      if (state.isLoading) return;

      cubit.loadTeamStatus();
    });
  }

  void _route(BuildContext context, TeamsState state) {
    if (state.hasTeam) {
      context.goNamed(AppRoutes.teamHomeName);
    } else if (state.hasNoTeam) {
      context.goNamed(AppRoutes.teamEmptyName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listener: _route,
      builder: (context, state) {
        if (state.isError) {
          return TeamScaffold(
            child: ErrorState(
              message: state.errorMessage ?? 'errors.generic',
              onRetry: context.read<TeamsCubit>().loadTeamStatus,
            ),
          );
        }
        return const _LoaderBody();
      },
    );
  }
}

class _LoaderBody extends StatelessWidget {
  const _LoaderBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TeamScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoaderRing(),
            const SizedBox(height: 20),
            ResponsiveText(
              'teams.loader.title',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 18,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              'teams.loader.subtitle',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.dateSoft,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
