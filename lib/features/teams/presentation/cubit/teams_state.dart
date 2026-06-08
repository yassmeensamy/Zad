import 'package:flutter/foundation.dart';

import '../../data/models/team_members_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_progress_model.dart';
import '../../data/models/team_progress_summary_model.dart';

enum TeamsStatus {
  idle,
  loading,
  noTeam,
  hasTeam,
  error,
}

enum CreateStatus { idle, submitting, success, error }

enum JoinStatus { idle, validating, preview, submitting, success, error }

enum LeaveStatus { idle, submitting, success, error }

class TeamsState {
  const TeamsState({
    this.status = TeamsStatus.idle,
    this.team,
    this.members,
    this.progress,
    this.summary,
    this.createStatus = CreateStatus.idle,
    this.createdTeam,
    this.joinStatus = JoinStatus.idle,
    this.joinedTeam,
    this.leaveStatus = LeaveStatus.idle,
    this.errorMessage,
  });

  final TeamsStatus status;
  final TeamModel? team;
  final TeamMembersModel? members;
  final TeamProgressModel? progress;
  final TeamProgressSummaryModel? summary;

  final CreateStatus createStatus;
  final TeamModel? createdTeam;

  final JoinStatus joinStatus;
  final TeamModel? joinedTeam;

  final LeaveStatus leaveStatus;

  final String? errorMessage;

  TeamsState copyWith({
    TeamsStatus? status,
    TeamModel? Function()? team,
    TeamMembersModel? Function()? members,
    TeamProgressModel? Function()? progress,
    TeamProgressSummaryModel? Function()? summary,
    CreateStatus? createStatus,
    TeamModel? Function()? createdTeam,
    JoinStatus? joinStatus,
    TeamModel? Function()? joinedTeam,
    LeaveStatus? leaveStatus,
    String? errorMessage,
  }) => TeamsState(
    status: status ?? this.status,
    team: team != null ? team() : this.team,
    members: members != null ? members() : this.members,
    progress: progress != null ? progress() : this.progress,
    summary: summary != null ? summary() : this.summary,
    createStatus: createStatus ?? this.createStatus,
    createdTeam: createdTeam != null ? createdTeam() : this.createdTeam,
    joinStatus: joinStatus ?? this.joinStatus,
    joinedTeam: joinedTeam != null ? joinedTeam() : this.joinedTeam,
    leaveStatus: leaveStatus ?? this.leaveStatus,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamsState &&
        other.status == status &&
        other.team == team &&
        other.members == members &&
        other.progress == progress &&
        other.summary == summary &&
        other.createStatus == createStatus &&
        other.createdTeam == createdTeam &&
        other.joinStatus == joinStatus &&
        other.joinedTeam == joinedTeam &&
        other.leaveStatus == leaveStatus &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    team,
    members,
    progress,
    summary,
    createStatus,
    createdTeam,
    joinStatus,
    joinedTeam,
    leaveStatus,
    errorMessage,
  ]);
}

extension TeamsStateX on TeamsState {
  bool get isLoading => status == TeamsStatus.loading;
  bool get isError => status == TeamsStatus.error;
  bool get hasTeam => status == TeamsStatus.hasTeam && team != null;
  bool get hasNoTeam => status == TeamsStatus.noTeam;
}

@immutable
class JoinPreview {
  const JoinPreview({
    required this.code,
    required this.teamName,
    required this.memberCount,
    required this.hostName,
  });

  final String code;
  final String teamName;
  final int memberCount;
  final String hostName;
}
