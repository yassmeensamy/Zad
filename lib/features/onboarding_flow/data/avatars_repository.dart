import 'dart:typed_data';

import 'avatar_model.dart';
import 'avatars_remote_data_source.dart';

abstract class AvatarsRepository {
  Future<List<AvatarModel>> getAvatars();
  Future<Uint8List> getAvatarImage(String id);
}

class AvatarsRepositoryImpl implements AvatarsRepository {
  AvatarsRepositoryImpl({required AvatarsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AvatarsRemoteDataSource _remoteDataSource;

  @override
  Future<List<AvatarModel>> getAvatars() => _remoteDataSource.getAvatars();

  @override
  Future<Uint8List> getAvatarImage(String id) =>
      _remoteDataSource.getAvatarImage(id);
}
