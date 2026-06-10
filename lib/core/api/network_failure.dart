import 'dart:io';

import 'package:dio/dio.dart';

/// Classifies whether [error] represents a *connectivity* failure (no internet,
/// timed-out connection) as opposed to a server-side error response.
///
/// The networking layer ([NetworkServiceImpl]) rethrows raw [DioException]s on
/// connectivity loss, while remote data sources convert HTTP error *responses*
/// into [ServerException]. The offline-first fallbacks must therefore branch on
/// this classifier — keying on it (and not on [ServerException]) is what lets
/// offline mode trigger while still surfacing genuine server errors unchanged.
bool isConnectivityError(Object error) {
  if (error is SocketException) return true;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return error.error is SocketException;
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;
    }
  }
  return false;
}
