import '../../models/child_model.dart';
import '../remote/child_remote_data_source.dart';

abstract class ChildRepository {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> createChild(NewChild child);
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    String? password,
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
  Future<ChildModel> createChild(NewChild child) =>
      _remoteDataSource.createChild(child);

  @override
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    String? password,
    DateTime? birthDate,
  }) => _remoteDataSource.updateChild(
    childId: childId,
    username: username,
    fullName: fullName,
    password: password,
    birthDate: birthDate,
  );

  @override
  Future<void> deleteChild(String childId) =>
      _remoteDataSource.deleteChild(childId);
}
