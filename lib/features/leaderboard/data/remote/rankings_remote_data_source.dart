import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/individual_rankings_response.dart';
import '../models/team_rankings_response.dart';

abstract class RankingsRemoteDataSource {
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

class RankingsRemoteDataSourceImpl implements RankingsRemoteDataSource {
  RankingsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<IndividualRankingsResponse> getIndividualRankings({
    int page = 0,
    int size = 20,
    int? categoryId,
  }) async {
    final response = await _networkService.get(
      _endpoints.rankingIndividuals,
      queryParameters: {
        'page': page,
        'size': size,
        'category_id': ?categoryId,
      },
    );
    _validateResponse(response);
    return IndividualRankingsResponse.fromMap(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<TeamRankingsResponse> getTeamRankings({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _networkService.get(
      _endpoints.rankingTeams,
      queryParameters: {'page': page, 'size': size},
    );
    _validateResponse(response);
    return TeamRankingsResponse.fromMap(
      response.data as Map<String, dynamic>,
    );
  }
}
