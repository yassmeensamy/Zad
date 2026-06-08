import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/loader_ring.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/teams_app_bar.dart';
import 'team_empty_screen.dart';
import 'team_home_screen.dart';

/// Entry point for the Teams flow and the single screen for all of its resting
/// states. Calls `getMyTeam()` (via [TeamsCubit.loadTeamStatus]), then swaps
/// only the body below a fixed [TeamsAppBar] — no route change, so the one
/// cubit survives and the bar never moves:
///   * loading  → parchment loader
///   * hasTeam  → [TeamHomeView]
///   * hasNoTeam→ [TeamEmptyView]
///   * error    → [ErrorState]
class TeamLoaderScreen extends StatefulWidget {
  const TeamLoaderScreen({super.key});

  @override
  State<TeamLoaderScreen> createState() => _TeamLoaderScreenState();
}

class _TeamLoaderScreenState extends State<TeamLoaderScreen> {
  bool _auxLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<TeamsCubit>();
      final state = cubit.state;

      // Already resolved with a team (e.g. arriving here after a successful
      // create) — just pull the auxiliary endpoints the home view needs.
      if (state.hasTeam) {
        _loadAuxData(cubit, state);
        return;
      }
      // Already settled on "no team", or a fetch is already in flight — wait.
      if (state.hasNoTeam || state.isLoading) return;

      cubit.loadTeamStatus();
    });
  }

  /// Members + progress aren't part of `getMyTeam()`; pull them once a team is
  /// known so the home view fills in beyond its skeleton.
  void _loadAuxData(TeamsCubit cubit, TeamsState state) {
    if (_auxLoaded) return;
    _auxLoaded = true;
    if (state.members == null) cubit.loadTeamMembers();
    if (state.progress == null) cubit.loadTeamProgress();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.hasTeam) {
          _loadAuxData(context.read<TeamsCubit>(), state);
        }
      },
      builder: (context, state) {
        return TeamScaffold(
          child: Column(
            children: [
              TeamsAppBar(state: state),
              Expanded(child: _body(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TeamsState state) {
    if (state.isError) {
      return ErrorState(
        message: state.errorMessage ?? 'errors.generic',
        onRetry: context.read<TeamsCubit>().loadTeamStatus,
      );
    }
    if (state.hasTeam) return const TeamHomeView();
    if (state.hasNoTeam) return const TeamEmptyView();
    return const _LoaderBody();
  }
}

class _LoaderBody extends StatelessWidget {
  const _LoaderBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
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
    );
  }
}
