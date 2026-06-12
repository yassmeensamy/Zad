import 'package:dio/dio.dart';

class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;

  final int? statusCode;

  factory ServerException.fromResponse(Response response) {
    final code = response.statusCode;
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) {
        return ServerException(m, statusCode: code);
      }
    }
    return ServerException('errors.generic', statusCode: code);
  }

  @override
  String toString() => 'ServerException($message, statusCode: $statusCode)';
}
