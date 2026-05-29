import '../models/individual_rankings_response.dart';
import '../models/team_rankings_response.dart';
import '../remote/rankings_remote_data_source.dart';

abstract class RankingsRepository {
  Future<IndividualRankingsResponse> getIndividualRankings({
    int page = 0,
    int size = 20,
    int? categoryId,
  });

  Future<TeamRankingsResponse> getTeamRankings({
    int page = 0,
    int size = 20,
  });
}

class RankingsRepositoryImpl implements RankingsRepository {
  RankingsRepositoryImpl({required RankingsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RankingsRemoteDataSource _remoteDataSource;

  @override
  Future<IndividualRankingsResponse> getIndividualRankings({
    int page = 0,
    int size = 20,
    int? categoryId,
  }) => _remoteDataSource.getIndividualRankings(
    page: page,
    size: size,
    categoryId: categoryId,
  );

  @override
  Future<TeamRankingsResponse> getTeamRankings({
    int page = 0,
    int size = 20,
  }) => _remoteDataSource.getTeamRankings(page: page, size: size);
}
