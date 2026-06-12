import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/create_team_request.dart';
import '../../data/models/join_team_request.dart';
import '../../data/models/team_progress_summary_model.dart';
import '../../data/repositories/teams_repository.dart';
import 'teams_state.dart';

class TeamsCubit extends BaseCubit<TeamsState> {
  TeamsCubit({required TeamsRepository repository})
    : _repository = repository,
      super(const TeamsState());

  final TeamsRepository _repository;

  Future<void> loadTeamStatus() async {
    emit(state.copyWith(status: TeamsStatus.loading));
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 400));
    try {
      final team = await _repository.getMyTeam();
      await minDelay;
      if (team.id.isEmpty) {
        emit(state.copyWith(status: TeamsStatus.noTeam, team: () => null));
      } else {
        emit(state.copyWith(status: TeamsStatus.hasTeam, team: () => team));
      }
    } on ServerException catch (e) {
      await minDelay;
      logger.debug('TeamsCubit.loadTeamStatus server: ${e.message}');
      emit(state.copyWith(status: TeamsStatus.noTeam, team: () => null));
      return;
    } catch (e) {
      logger.error('TeamsCubit.loadTeamStatus failed: $e');
      await minDelay;
      emit(
        state.copyWith(
          status: TeamsStatus.error,
          errorMessage: 'errors.generic',
        ),
      );
    }
  }

  Future<void> refreshTeam() async {
    try {
      final team = await _repository.getMyTeam();
      if (team.id.isEmpty) {
        _emitNoTeam();
      } else {
        emit(state.copyWith(status: TeamsStatus.hasTeam, team: () => team));
      }
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        _emitNoTeam();
        return;
      }
      logger.error('TeamsCubit.refreshTeam server: ${e.message}');
    } catch (e) {
      logger.error('TeamsCubit.refreshTeam failed: $e');
    }
  }

  Future<void> _confirmNoTeam() async {
    try {
      await _repository.getMyTeam();
    } catch (_) {
    }
  }

  void _emitNoTeam() {
    emit(
      state.copyWith(
        status: TeamsStatus.noTeam,
        team: () => null,
        members: () => null,
        progress: () => null,
        summary: () => null,
        progressCategoryId: () => null,
        progressLoading: false,
      ),
    );
  }

  Future<void> loadTeamMembers() async {
    try {
      final members = await _repository.getMyTeamMembers();
      emit(state.copyWith(members: () => members));
    } catch (e) {
      logger.error('TeamsCubit.loadTeamMembers failed: $e');
    }
  }

  Future<void> loadTeamProgress({int? categoryId}) async {
    emit(
      state.copyWith(
        progressCategoryId: () => categoryId,
        progressLoading: true,
      ),
    );
    try {
      final progress = await _repository.getMyTeamProgress(
        categoryId: categoryId,
      );
      emit(
        state.copyWith(
          progress: () => progress,
          summary: categoryId == null
              ? () => TeamProgressSummaryModel.fromProgress(progress)
              : null,
          progressLoading: false,
        ),
      );
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        _emitNoTeam();
        return;
      }
      logger.error('TeamsCubit.loadTeamProgress server: ${e.message}');
      emit(state.copyWith(progressLoading: false));
    } catch (e) {
      logger.error('TeamsCubit.loadTeamProgress failed: $e');
      emit(state.copyWith(progressLoading: false));
    }
  }

  Future<void> createTeam({required String name}) async {
    emit(state.copyWith(createStatus: CreateStatus.submitting));
    try {
      final created = await _repository.createTeam(
        CreateTeamRequest(name: name),
      );
      final team = await _repository.getMyTeam();
      final hydrated = team.copyWith(joinCode: created.joinCode);
      emit(
        state.copyWith(
          status: TeamsStatus.hasTeam,
          team: () => hydrated,
          createStatus: CreateStatus.success,
          createdTeam: () => hydrated,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          createStatus: CreateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      logger.error('TeamsCubit.createTeam failed: $e');
      emit(
        state.copyWith(
          createStatus: CreateStatus.error,
          errorMessage: 'errors.generic',
        ),
      );
    }
  }

  void resetCreateState() {
    emit(
      state.copyWith(
        createStatus: CreateStatus.idle,
        createdTeam: () => null,
      ),
    );
  }

  Future<void> joinTeam({required String joinCode}) async {
    emit(state.copyWith(joinStatus: JoinStatus.submitting));
    try {
      await _repository.joinTeam(JoinTeamRequest(joinCode: joinCode));
      final team = await _repository.getMyTeam();
      emit(
        state.copyWith(
          status: TeamsStatus.hasTeam,
          team: () => team,
          joinStatus: JoinStatus.success,
          joinedTeam: () => team,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          joinStatus: JoinStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      logger.error('TeamsCubit.joinTeam failed: $e');
      emit(
        state.copyWith(
          joinStatus: JoinStatus.error,
          errorMessage: 'errors.generic',
        ),
      );
    }
  }

  void resetJoinState() {
    emit(
      state.copyWith(
        joinStatus: JoinStatus.idle,
        joinedTeam: () => null,
      ),
    );
  }

  Future<void> leaveTeam() async {
    emit(state.copyWith(leaveStatus: LeaveStatus.submitting));
    try {
      await _repository.leaveTeam();
      await _confirmNoTeam();
      emit(
        state.copyWith(
          leaveStatus: LeaveStatus.success,
          status: TeamsStatus.noTeam,
          team: () => null,
          members: () => null,
          progress: () => null,
          summary: () => null,
          progressCategoryId: () => null,
          progressLoading: false,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          leaveStatus: LeaveStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      logger.error('TeamsCubit.leaveTeam failed: $e');
      emit(
        state.copyWith(
          leaveStatus: LeaveStatus.error,
          errorMessage: 'errors.generic',
        ),
      );
    }
  }

  void resetLeaveState() {
    emit(state.copyWith(leaveStatus: LeaveStatus.idle));
  }
}
