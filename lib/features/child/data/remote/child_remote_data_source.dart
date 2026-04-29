import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../models/child_model.dart';

abstract class ChildRemoteDataSource {
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
    String? password,
    DateTime? birthDate,
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

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<List<ChildModel>> getChildren() async {
    final response = await _networkService.get(_endpoints.children);
    _validateResponse(response);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ChildModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChildModel> createChild({
    required String username,
    required String fullName,
    required String password,
    DateTime? birthDate,
  }) async {
    final response = await _networkService.post(
      _endpoints.createChild,
      data: {
        'username': username,
        'fullName': fullName,
        'password': password,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      },
    );
    _validateResponse(response);
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
  }) async {
    final response = await _networkService.put(
      _endpoints.childById(childId),
      data: {
        'username': ?username,
        'fullName': ?fullName,
        'password': ?password,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      },
    );
    _validateResponse(response);
    return ChildModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteChild(String childId) async {
    final response = await _networkService.delete(
      _endpoints.childById(childId),
    );
    _validateResponse(response, [200, 204]);
  }
}
