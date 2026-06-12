import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../leaderboard/data/models/individual_ranking_model.dart';
import '../../../leaderboard/data/repositories/rankings_repository.dart';
import '../../data/repositories/quiz_stats_repository.dart';
import 'quiz_stats_state.dart';

/// Aggregates the user's quiz statistics:
///  - `GET /api/quiz/stats/weekly`
///  - `GET /api/quiz/stats/total-solved`
///  - the authenticated user's rank from `GET /api/rankings/individuals`
///    (reused via [RankingsRepository], best-effort so a guest/ranking failure
///    never blocks the core stats).
class QuizStatsCubit extends BaseCubit<QuizStatsState> {
  QuizStatsCubit({
    required QuizStatsRepository repository,
    required RankingsRepository rankingsRepository,
  }) : _repository = repository,
       _rankingsRepository = rankingsRepository,
       super(const QuizStatsState());

  final QuizStatsRepository _repository;
  final RankingsRepository _rankingsRepository;

  /// Loads all stats. Safe to call again for pull-to-refresh.
  Future<void> load() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: QuizStatsStatus.loading,
        errorMessage: () => null,
      ),
    );

    try {
      // Fire both core calls concurrently, awaiting each so the types are kept.
      final weeklyFuture = _repository.getWeeklyStats();
      final totalFuture = _repository.getTotalSolved();
      final weekly = await weeklyFuture;
      final total = await totalFuture;

      // Rank is supplementary — never let it fail the whole screen.
      final myRank = await _loadMyRank();

      emit(
        state.copyWith(
          status: QuizStatsStatus.success,
          weekly: () => weekly,
          totalSolved: () => total,
          myRank: () => myRank,
        ),
      );
    } on ServerException catch (e) {
      logger.debug('QuizStatsCubit.load server: ${e.message}');
      _emitError(e.message);
    } catch (e) {
      logger.error('QuizStatsCubit.load failed: $e');
      _emitError('errors.generic');
    }
  }

  Future<void> refresh() => load();

  Future<MyIndividualRank?> _loadMyRank() async {
    try {
      final res = await _rankingsRepository.getIndividualRankings(
        page: 0,
        size: 1,
      );
      return res.myRank;
    } catch (e) {
      logger.debug('QuizStatsCubit._loadMyRank skipped: $e');
      return null;
    }
  }

  void _emitError(String? message) {
    emit(
      state.copyWith(
        status: QuizStatsStatus.error,
        errorMessage: () => message,
      ),
    );
  }
}
