import '../../../leaderboard/data/models/individual_ranking_model.dart';
import '../../data/models/total_solved_response.dart';
import '../../data/models/weekly_stats_response.dart';

enum QuizStatsStatus { idle, loading, success, error }

class QuizStatsState {
  const QuizStatsState({
    this.status = QuizStatsStatus.idle,
    this.weekly,
    this.totalSolved,
    this.myRank,
    this.errorMessage,
  });

  final QuizStatsStatus status;
  final WeeklyStatsResponse? weekly;
  final TotalSolvedResponse? totalSolved;

  /// The authenticated user's individual leaderboard rank, sourced from
  /// `GET /api/rankings/individuals`. Null for guests or when ranking is off.
  final MyIndividualRank? myRank;

  final String? errorMessage;

  QuizStatsState copyWith({
    QuizStatsStatus? status,
    WeeklyStatsResponse? Function()? weekly,
    TotalSolvedResponse? Function()? totalSolved,
    MyIndividualRank? Function()? myRank,
    String? Function()? errorMessage,
  }) => QuizStatsState(
    status: status ?? this.status,
    weekly: weekly != null ? weekly() : this.weekly,
    totalSolved: totalSolved != null ? totalSolved() : this.totalSolved,
    myRank: myRank != null ? myRank() : this.myRank,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizStatsState &&
        other.status == status &&
        other.weekly == weekly &&
        other.totalSolved == totalSolved &&
        other.myRank == myRank &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(status, weekly, totalSolved, myRank, errorMessage);
}

extension QuizStatsStateX on QuizStatsState {
  bool get isLoading => status == QuizStatsStatus.loading;
  bool get isSuccess => status == QuizStatsStatus.success;
  bool get isError => status == QuizStatsStatus.error;

  int get totalSolvedQuestions => totalSolved?.totalSolvedQuestions ?? 0;
  int get solvedLastWeek => weekly?.solvedLastWeek ?? 0;
}
