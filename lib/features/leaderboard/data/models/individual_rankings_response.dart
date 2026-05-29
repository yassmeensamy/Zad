import 'dart:convert';

import 'individual_ranking_model.dart';
import 'ranking_pagination.dart';

/// Response envelope for `GET /api/rankings/individuals`.
class IndividualRankingsResponse {
  const IndividualRankingsResponse({
    required this.pagination,
    required this.rankings,
    this.myRank,
  });

  final RankingPagination pagination;
  final List<IndividualRankingModel> rankings;
  final MyIndividualRank? myRank;

  factory IndividualRankingsResponse.fromMap(Map<String, dynamic> map) =>
      IndividualRankingsResponse(
        pagination: RankingPagination.fromMap(
          (map['pagination'] as Map<String, dynamic>?) ?? const {},
        ),
        myRank: map['myRank'] == null
            ? null
            : MyIndividualRank.fromMap(map['myRank'] as Map<String, dynamic>),
        rankings: (map['rankings'] as List<dynamic>? ?? const [])
            .map(
              (e) => IndividualRankingModel.fromMap(e as Map<String, dynamic>),
            )
            .toList(),
      );

  factory IndividualRankingsResponse.fromJson(String source) =>
      IndividualRankingsResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'IndividualRankingsResponse(${rankings.length} rows, $pagination)';
}
