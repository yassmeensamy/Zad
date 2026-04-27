import '../../models/child_model.dart';
import '../remote/child_remote_data_source.dart';

abstract class ChildRepository {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> createChild({
    required String username,
    required String fullName,
    required String password,
    DateTime? birthDate,
  });
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    DateTime? birthDate,
  });
  Future<void> deleteChild(String childId);
}

class ChildRepositoryImpl implements ChildRepository {
  ChildRepositoryImpl({required ChildRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ChildRemoteDataSource _remoteDataSource;

  @override
  Future<List<ChildModel>> getChildren() => _remoteDataSource.getChildren();

  @override
  Future<ChildModel> createChild({
    required String username,
    required String fullName,
    required String password,
    DateTime? birthDate,
  }) => _remoteDataSource.createChild(
    username: username,
    fullName: fullName,
    password: password,
    birthDate: birthDate,
  );

  @override
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    DateTime? birthDate,
  }) => _remoteDataSource.updateChild(
    childId: childId,
    username: username,
    fullName: fullName,
    birthDate: birthDate,
  );

  @override
  Future<void> deleteChild(String childId) =>
      _remoteDataSource.deleteChild(childId);
}
