import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/api/endpoints/app_endpoints.dart';
import '../../../core/api/network_service.dart';
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

  @override
  Future<List<AvatarModel>> getAvatars() async {
    final response = await _networkService.get(_endpoints.avatars);
    response.validated();
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
    response.validated();
    return Uint8List.fromList(response.data as List<int>);
  }
}
