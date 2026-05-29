import 'package:flutter/foundation.dart';

import '../../data/models/individual_ranking_model.dart';
import '../../data/models/ranking_pagination.dart';
import '../../data/models/team_ranking_model.dart';

enum RankingsScope {
  individuals,
  teams;

  String get labelKey => switch (this) {
    RankingsScope.individuals => 'leaderboard.scope.individuals',
    RankingsScope.teams => 'leaderboard.scope.teams',
  };
}

enum RankingsStatus { idle, loading, success, error }

class RankingsState {
  const RankingsState({
    this.scope = RankingsScope.individuals,
    this.categoryId,
    this.individualStatus = RankingsStatus.idle,
    this.individuals = const [],
    this.myRank,
    this.individualPagination,
    this.teamStatus = RankingsStatus.idle,
    this.teams = const [],
    this.myTeamRank,
    this.teamPagination,
    this.loadingMore = false,
    this.errorMessage,
  });

  final RankingsScope scope;

  final int? categoryId;

  final RankingsStatus individualStatus;
  final List<IndividualRankingModel> individuals;
  final MyIndividualRank? myRank;
  final RankingPagination? individualPagination;

  final RankingsStatus teamStatus;
  final List<TeamRankingModel> teams;
  final MyTeamRank? myTeamRank;
  final RankingPagination? teamPagination;

  final bool loadingMore;
  final String? errorMessage;

  RankingsState copyWith({
    RankingsScope? scope,
    int? Function()? categoryId,
    RankingsStatus? individualStatus,
    List<IndividualRankingModel>? individuals,
    MyIndividualRank? Function()? myRank,
    RankingPagination? Function()? individualPagination,
    RankingsStatus? teamStatus,
    List<TeamRankingModel>? teams,
    MyTeamRank? Function()? myTeamRank,
    RankingPagination? Function()? teamPagination,
    bool? loadingMore,
    String? Function()? errorMessage,
  }) => RankingsState(
    scope: scope ?? this.scope,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    individualStatus: individualStatus ?? this.individualStatus,
    individuals: individuals ?? this.individuals,
    myRank: myRank != null ? myRank() : this.myRank,
    individualPagination: individualPagination != null
        ? individualPagination()
        : this.individualPagination,
    teamStatus: teamStatus ?? this.teamStatus,
    teams: teams ?? this.teams,
    myTeamRank: myTeamRank != null ? myTeamRank() : this.myTeamRank,
    teamPagination: teamPagination != null
        ? teamPagination()
        : this.teamPagination,
    loadingMore: loadingMore ?? this.loadingMore,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RankingsState &&
        other.scope == scope &&
        other.categoryId == categoryId &&
        other.individualStatus == individualStatus &&
        listEquals(other.individuals, individuals) &&
        other.myRank == myRank &&
        other.individualPagination == individualPagination &&
        other.teamStatus == teamStatus &&
        listEquals(other.teams, teams) &&
        other.myTeamRank == myTeamRank &&
        other.teamPagination == teamPagination &&
        other.loadingMore == loadingMore &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    scope,
    categoryId,
    individualStatus,
    Object.hashAll(individuals),
    myRank,
    individualPagination,
    teamStatus,
    Object.hashAll(teams),
    myTeamRank,
    teamPagination,
    loadingMore,
    errorMessage,
  ]);
}

extension RankingsStateX on RankingsState {
  bool get isIndividuals => scope == RankingsScope.individuals;
  bool get isTeams => scope == RankingsScope.teams;

  RankingsStatus get activeStatus =>
      isIndividuals ? individualStatus : teamStatus;

  bool get activeIsEmpty =>
      isIndividuals ? individuals.isEmpty : teams.isEmpty;

  bool get canLoadMore {
    final p = isIndividuals ? individualPagination : teamPagination;
    return p != null && p.hasNext;
  }

  int get activeCount => isIndividuals ? individuals.length : teams.length;
}
