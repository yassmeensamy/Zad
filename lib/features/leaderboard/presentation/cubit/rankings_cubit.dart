import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/rankings_repository.dart';
import 'rankings_state.dart';

class RankingsCubit extends BaseCubit<RankingsState> {
  RankingsCubit({required RankingsRepository repository})
    : _repository = repository,
      super(const RankingsState());

  final RankingsRepository _repository;

  static const int _pageSize = 20;

  Future<void> loadInitial() async {
    if (state.isIndividuals) {
      if (state.individuals.isEmpty &&
          state.individualStatus != RankingsStatus.loading) {
        await _loadIndividuals(reset: true);
      }
    } else {
      if (state.teams.isEmpty && state.teamStatus != RankingsStatus.loading) {
        await _loadTeams(reset: true);
      }
    }
  }

  Future<void> setScope(RankingsScope scope) async {
    if (scope == state.scope) return;
    emit(state.copyWith(scope: scope, loadingMore: false));
    await loadInitial();
  }

  Future<void> setCategory(int? categoryId) async {
    if (categoryId == state.categoryId) return;
    emit(state.copyWith(categoryId: () => categoryId));
    await _loadIndividuals(reset: true);
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.canLoadMore) return;
    if (state.isIndividuals) {
      await _loadIndividuals(reset: false);
    } else {
      await _loadTeams(reset: false);
    }
  }

  Future<void> refresh() async {
    if (state.isIndividuals) {
      await _loadIndividuals(reset: true);
    } else {
      await _loadTeams(reset: true);
    }
  }

  Future<void> _loadIndividuals({required bool reset}) async {
    final nextPage = reset
        ? 0
        : (state.individualPagination?.currentPage ?? -1) + 1;

    emit(
      reset
          ? state.copyWith(
              individualStatus: RankingsStatus.loading,
              individuals: const [],
              individualPagination: () => null,
              errorMessage: () => null,
            )
          : state.copyWith(loadingMore: true),
    );

    try {
      final res = await _repository.getIndividualRankings(
        page: nextPage,
        size: _pageSize,
        categoryId: state.categoryId,
      );
      final merged = reset
          ? res.rankings
          : [...state.individuals, ...res.rankings];
      emit(
        state.copyWith(
          individualStatus: RankingsStatus.success,
          individuals: merged,
          myRank: () => res.myRank,
          individualPagination: () => res.pagination,
          loadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      logger.debug('RankingsCubit._loadIndividuals server: ${e.message}');
      _emitIndividualError(reset, e.message);
    } catch (e) {
      logger.error('RankingsCubit._loadIndividuals failed: $e');
      _emitIndividualError(reset, 'errors.generic');
    }
  }

  Future<void> _loadTeams({required bool reset}) async {
    final nextPage = reset ? 0 : (state.teamPagination?.currentPage ?? -1) + 1;

    emit(
      reset
          ? state.copyWith(
              teamStatus: RankingsStatus.loading,
              teams: const [],
              teamPagination: () => null,
              errorMessage: () => null,
            )
          : state.copyWith(loadingMore: true),
    );

    try {
      final res = await _repository.getTeamRankings(
        page: nextPage,
        size: _pageSize,
      );
      final merged = reset ? res.rankings : [...state.teams, ...res.rankings];
      emit(
        state.copyWith(
          teamStatus: RankingsStatus.success,
          teams: merged,
          myTeamRank: () => res.myTeamRank,
          teamPagination: () => res.pagination,
          loadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      logger.debug('RankingsCubit._loadTeams server: ${e.message}');
      _emitTeamError(reset, e.message);
    } catch (e) {
      logger.error('RankingsCubit._loadTeams failed: $e');
      _emitTeamError(reset, 'errors.generic');
    }
  }

  void _emitIndividualError(bool reset, String? message) {
    emit(
      state.copyWith(
        individualStatus: reset ? RankingsStatus.error : state.individualStatus,
        loadingMore: false,
        errorMessage: () => message,
      ),
    );
  }

  void _emitTeamError(bool reset, String? message) {
    emit(
      state.copyWith(
        teamStatus: reset ? RankingsStatus.error : state.teamStatus,
        loadingMore: false,
        errorMessage: () => message,
      ),
    );
  }
}
