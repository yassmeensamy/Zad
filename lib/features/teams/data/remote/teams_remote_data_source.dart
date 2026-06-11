import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/create_team_request.dart';
import '../models/created_team_model.dart';
import '../models/join_team_request.dart';
import '../models/joined_team_model.dart';
import '../models/team_members_model.dart';
import '../models/team_model.dart';
import '../models/team_progress_model.dart';
import '../models/team_progress_summary_model.dart';

abstract class TeamsRemoteDataSource {
  Future<TeamModel> getMyTeam();
  Future<TeamMembersModel> getMyTeamMembers();

  /// Fetches team progress. With [categoryId] omitted, returns total progress
  /// per member across all categories. With a [categoryId], the response also
  /// includes a per-member breakdown scoped to that category.
  Future<TeamProgressModel> getMyTeamProgress({int? categoryId});
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary();
  Future<CreatedTeamModel> createTeam(CreateTeamRequest request);
  Future<JoinedTeamModel> joinTeam(JoinTeamRequest request);
  Future<void> leaveTeam();
}

class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  TeamsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<TeamModel> getMyTeam() async {
    final response = await _networkService.get(_endpoints.myTeam);
    response.validated();
    return TeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamMembersModel> getMyTeamMembers() async {
    final response = await _networkService.get(_endpoints.myTeamMembers);
    response.validated();
    return TeamMembersModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamProgressModel> getMyTeamProgress({int? categoryId}) async {
    final response = await _networkService.get(
      _endpoints.myTeamProgress,
      queryParameters: categoryId == null ? null : {'category': categoryId},
    );
    response.validated();
    return TeamProgressModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary() async {
    final response = await _networkService.get(
      _endpoints.myTeamProgressSummary,
    );
    response.validated();
    return TeamProgressSummaryModel.fromMap(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CreatedTeamModel> createTeam(CreateTeamRequest request) async {
    final response = await _networkService.post(
      _endpoints.teams,
      data: request.toMap(),
    );
    response.validated([201]);
    return CreatedTeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<JoinedTeamModel> joinTeam(JoinTeamRequest request) async {
    final response = await _networkService.post(
      _endpoints.joinTeam,
      data: request.toMap(),
    );
    response.validated([200]);
    return JoinedTeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> leaveTeam() async {
    final response = await _networkService.delete(_endpoints.leaveTeam);
    response.validated([204]);
  }
}
