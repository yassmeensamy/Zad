import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/api/endpoints/app_endpoints.dart';
import '../../../core/api/network_service.dart';
import '../../../core/expections/server_exception.dart';
import '../../../core/utils/logger.dart';
import 'avatar_model.dart';

abstract class AvatarsRemoteDataSource {
  Future<List<AvatarModel>> getAvatars();
  Future<Uint8List> getAvatarImage(String id);
}

class AvatarsRemoteDataSourceImpl implements AvatarsRemoteDataSource {
  AvatarsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<List<AvatarModel>> getAvatars() async {
    final response = await _networkService.get(_endpoints.avatars);
    _validateResponse(response);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AvatarModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Uint8List> getAvatarImage(String id) async {
    final response = await _networkService.get(
      _endpoints.avatarImage(id),
      responseType: ResponseType.bytes,
    );
    _validateResponse(response);
    return Uint8List.fromList(response.data as List<int>);
  }
}
