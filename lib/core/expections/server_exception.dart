import 'package:dio/dio.dart';

class ServerException implements Exception {
  const ServerException(this.message);

  final String message;

  factory ServerException.fromResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return ServerException(m);
    }
    return const ServerException('errors.generic');
  }

  @override
  String toString() => 'ServerException($message)';
}
