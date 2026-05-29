import 'dart:convert';

import 'ranking_pagination.dart';
import 'team_ranking_model.dart';

class TeamRankingsResponse {
  const TeamRankingsResponse({
    required this.pagination,
    required this.rankings,
    this.myTeamRank,
  });

  final RankingPagination pagination;
  final List<TeamRankingModel> rankings;
  final MyTeamRank? myTeamRank;

  factory TeamRankingsResponse.fromMap(Map<String, dynamic> map) =>
      TeamRankingsResponse(
        pagination: RankingPagination.fromMap(
          (map['pagination'] as Map<String, dynamic>?) ?? const {},
        ),
        myTeamRank: map['myTeamRank'] == null
            ? null
            : MyTeamRank.fromMap(map['myTeamRank'] as Map<String, dynamic>),
        rankings: (map['rankings'] as List<dynamic>? ?? const [])
            .map((e) => TeamRankingModel.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  factory TeamRankingsResponse.fromJson(String source) =>
      TeamRankingsResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'TeamRankingsResponse(${rankings.length} rows, $pagination)';
}
