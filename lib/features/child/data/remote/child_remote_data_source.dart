import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/utils/logger.dart';
import '../../models/child_model.dart';

abstract class ChildRemoteDataSource {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> createChild(NewChild child);
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    String? password,
    DateTime? birthDate,
    String? avatarId,
  });
  Future<void> deleteChild(String childId);
}

class ChildRemoteDataSourceImpl implements ChildRemoteDataSource {
  ChildRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<List<ChildModel>> getChildren() async {
    final response = await _networkService.get(_endpoints.children);
    response.validated();
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ChildModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChildModel> createChild(NewChild child) async {
    final response = await _networkService.post(
      _endpoints.createChild,
      data: {
        'username': child.username,
        'fullName': child.fullName,
        'password': child.password,
        if (child.birthDate != null)
          'birthDate': child.birthDate!.toIso8601String(),
      },
    );
    response.validated();
    logger.debug('createChild response: ${response.data}');
    return ChildModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<ChildModel> updateChild({
    required String childId,
    String? username,
    String? fullName,
    String? password,
    DateTime? birthDate,
    String? avatarId,
  }) async {
    final response = await _networkService.put(
      _endpoints.childById(childId),
      data: {
        'username': ?username,
        'fullName': ?fullName,
        'password': ?password,
        'avatarId': ?avatarId,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      },
    );
    response.validated();
    return ChildModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteChild(String childId) async {
    final response = await _networkService.delete(
      _endpoints.childById(childId),
    );
    response.validated([200, 204]);
  }
}
