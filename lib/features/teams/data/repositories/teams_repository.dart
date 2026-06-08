import '../models/create_team_request.dart';
import '../models/created_team_model.dart';
import '../models/join_team_request.dart';
import '../models/joined_team_model.dart';
import '../models/team_members_model.dart';
import '../models/team_model.dart';
import '../models/team_progress_model.dart';
import '../models/team_progress_summary_model.dart';
import '../remote/teams_remote_data_source.dart';

abstract class TeamsRepository {
  Future<TeamModel> getMyTeam();
  Future<TeamMembersModel> getMyTeamMembers();
  Future<TeamProgressModel> getMyTeamProgress({int? categoryId});
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary();
  Future<CreatedTeamModel> createTeam(CreateTeamRequest request);
  Future<JoinedTeamModel> joinTeam(JoinTeamRequest request);
  Future<void> leaveTeam();
}

class TeamsRepositoryImpl implements TeamsRepository {
  TeamsRepositoryImpl({required TeamsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TeamsRemoteDataSource _remoteDataSource;

  @override
  Future<TeamModel> getMyTeam() => _remoteDataSource.getMyTeam();

  @override
  Future<TeamMembersModel> getMyTeamMembers() =>
      _remoteDataSource.getMyTeamMembers();

  @override
  Future<TeamProgressModel> getMyTeamProgress({int? categoryId}) =>
      _remoteDataSource.getMyTeamProgress(categoryId: categoryId);

  @override
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary() =>
      _remoteDataSource.getMyTeamProgressSummary();

  @override
  Future<CreatedTeamModel> createTeam(CreateTeamRequest request) =>
      _remoteDataSource.createTeam(request);

  @override
  Future<JoinedTeamModel> joinTeam(JoinTeamRequest request) =>
      _remoteDataSource.joinTeam(request);

  @override
  Future<void> leaveTeam() => _remoteDataSource.leaveTeam();
}
