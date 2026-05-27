import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_team_request.dart';
import '../models/created_team_model.dart';
import '../models/join_team_request.dart';
import '../models/joined_team_model.dart';
import '../models/leaderboard_timeframe_enum.dart';
import '../models/member_activity_status_enum.dart';
import '../models/team_member_progress_model.dart';
import '../models/team_members_model.dart';
import '../models/team_model.dart';
import '../models/team_progress_model.dart';
import '../models/team_progress_summary_model.dart';

abstract class TeamsRemoteDataSource {
  Future<TeamModel> getMyTeam();
  Future<TeamMembersModel> getMyTeamMembers();
  Future<TeamProgressModel> getMyTeamProgress();
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary();
  Future<List<TeamMemberProgressModel>> getMyTeamLeaderboard(
    LeaderboardTimeframe timeframe,
  );
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

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201, 204],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<TeamModel> getMyTeam() async {
    final response = await _networkService.get(_endpoints.myTeam);
    _validateResponse(response);
    return TeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamMembersModel> getMyTeamMembers() async {
    final response = await _networkService.get(_endpoints.myTeamMembers);
    _validateResponse(response);
    return TeamMembersModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamProgressModel> getMyTeamProgress() async {
    final response = await _networkService.get(_endpoints.myTeamProgress);
    _validateResponse(response);
    return TeamProgressModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<TeamProgressSummaryModel> getMyTeamProgressSummary() async {
    final response =
        await _networkService.get(_endpoints.myTeamProgressSummary);
    _validateResponse(response);
    return TeamProgressSummaryModel.fromMap(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<TeamMemberProgressModel>> getMyTeamLeaderboard(
    LeaderboardTimeframe timeframe,
  ) async {
    // TODO(leaderboard): replace mock with a real endpoint once the backend
    // exposes per-timeframe rankings. Until then, return a stable, sorted
    // mock so the leaderboard UI can be developed and reviewed end-to-end.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _buildMockLeaderboard(timeframe);
  }

  @override
  Future<CreatedTeamModel> createTeam(CreateTeamRequest request) async {
    final response = await _networkService.post(
      _endpoints.teams,
      data: request.toMap(),
    );
    _validateResponse(response);
    return CreatedTeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<JoinedTeamModel> joinTeam(JoinTeamRequest request) async {
    final response = await _networkService.post(
      _endpoints.joinTeam,
      data: request.toMap(),
    );
    _validateResponse(response);
    return JoinedTeamModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> leaveTeam() async {
    final response = await _networkService.delete(_endpoints.leaveTeam);
    _validateResponse(response);
  }
}

// ─── Mock leaderboard data ─────────────────────────────────────────────
//
// Standalone so the screen layer stays free of stub data. The roster
// stays constant per timeframe; only `completedLevels` scales (week →
// month → all-time) and the ordering is reshuffled so each tab shows a
// slightly different podium. Result is sorted descending so the screen
// can render the list as-is.

List<TeamMemberProgressModel> _buildMockLeaderboard(
  LeaderboardTimeframe timeframe,
) {
  final mult = switch (timeframe) {
    LeaderboardTimeframe.week => 1.0,
    LeaderboardTimeframe.month => 2.6,
    LeaderboardTimeframe.allTime => 6.4,
  };
  final reshuffle = switch (timeframe) {
    LeaderboardTimeframe.week =>
      const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    LeaderboardTimeframe.month =>
      const <int>[1, 0, 3, 2, 5, 4, 7, 6, 8, 10, 9, 11],
    LeaderboardTimeframe.allTime =>
      const <int>[2, 0, 1, 4, 3, 6, 5, 8, 7, 9, 11, 10],
  };
  final scaled = [
    for (var i = 0; i < _mockRoster.length; i++)
      _mockRoster[reshuffle[i]].copyWith(
        completedLevels:
            (_mockRoster[reshuffle[i]].completedLevels * mult).round().clamp(
                  0,
                  _mockRoster[reshuffle[i]].totalLevels,
                ),
      ),
  ]..sort((a, b) => b.completedLevels.compareTo(a.completedLevels));
  return scaled;
}

const List<TeamMemberProgressModel> _mockRoster = [
  TeamMemberProgressModel(
    userId: 'u1',
    username: 'Yusuf',
    completedLevels: 18,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.consistent,
  ),
  TeamMemberProgressModel(
    userId: 'u2',
    username: 'Maryam',
    completedLevels: 16,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.active,
  ),
  TeamMemberProgressModel(
    userId: 'u3',
    username: 'Hamza',
    completedLevels: 14,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.consistent,
  ),
  TeamMemberProgressModel(
    userId: 'u4',
    username: 'Aisha',
    completedLevels: 12,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.active,
  ),
  TeamMemberProgressModel(
    userId: 'u5',
    username: 'Bilal',
    completedLevels: 11,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.active,
  ),
  TeamMemberProgressModel(
    userId: 'u6',
    username: 'Khadija',
    completedLevels: 10,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.consistent,
  ),
  TeamMemberProgressModel(
    userId: 'u7',
    username: 'Idris',
    completedLevels: 9,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.idle,
  ),
  TeamMemberProgressModel(
    userId: 'u8',
    username: 'Zaynab',
    completedLevels: 8,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.active,
  ),
  TeamMemberProgressModel(
    userId: 'u9',
    username: 'Omar',
    completedLevels: 7,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.idle,
  ),
  TeamMemberProgressModel(
    userId: 'u10',
    username: 'Layla',
    completedLevels: 6,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.consistent,
  ),
  TeamMemberProgressModel(
    userId: 'u11',
    username: 'Salma',
    completedLevels: 4,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.idle,
  ),
  TeamMemberProgressModel(
    userId: 'u12',
    username: 'Tariq',
    completedLevels: 3,
    totalLevels: 40,
    activityStatus: MemberActivityStatus.idle,
  ),
];
