import 'dart:convert';

/// Response body for `GET /api/quiz/stats/total-solved`.
class TotalSolvedResponse {
  const TotalSolvedResponse({required this.totalSolvedQuestions});

  /// Lifetime count of questions the user has solved.
  final int totalSolvedQuestions;

  factory TotalSolvedResponse.fromMap(Map<String, dynamic> map) =>
      TotalSolvedResponse(
        totalSolvedQuestions:
            (map['totalSolvedQuestions'] as num?)?.toInt() ?? 0,
      );

  factory TotalSolvedResponse.fromJson(String source) =>
      TotalSolvedResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TotalSolvedResponse(totalSolvedQuestions: $totalSolvedQuestions)';
}
