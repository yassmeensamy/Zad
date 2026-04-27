class ServerException implements Exception {
  const ServerException({
    required this.status,
    required this.error,
    required this.message,
    required this.path,
    required this.timestamp,
  });

  final int status;
  final String error;
  final String message;
  final String path;
  final DateTime timestamp;

  factory ServerException.fromMap(Map<String, dynamic> map) => ServerException(
        status: map['status'] as int,
        error: map['error'] as String,
        message: map['message'] as String,
        path: map['path'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  @override
  String toString() =>
      'ServerException(status: $status, error: $error, message: $message, path: $path, timestamp: $timestamp)';
}
