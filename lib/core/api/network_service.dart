import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:requests_inspector/requests_inspector.dart';

import 'auth_interceptor.dart';
import 'language_interceptor.dart';
import '../services/core_service_locator.dart';

import '../utils/logger.dart';
import 'app_info_interceptor.dart';
import 'app_type_interceptor.dart';

enum HttpMethod { get, post, put, patch, delete }

class NetworkRequest {
  final HttpMethod method;
  final String url;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  final ResponseType responseType;
  final bool skipAuth;
  CancelToken? cancelToken;

  NetworkRequest({
    required this.method,
    required this.url,
    this.data,
    this.queryParameters,
    this.headers,
    this.responseType = ResponseType.json,
    this.skipAuth = false,
    this.cancelToken,
  });
}

abstract class NetworkService {
  Future<Response> execute(NetworkRequest request);

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType,
    bool skipAuth,
    CancelToken? cancelToken,
  });

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType,
    bool skipAuth,
    CancelToken? cancelToken,
  });

  Future<Response> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType,
    bool skipAuth,
    CancelToken? cancelToken,
  });

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType,
    bool skipAuth,
    CancelToken? cancelToken,
  });

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType,
    bool skipAuth,
    CancelToken? cancelToken,
  });

  Future<Response> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool skipAuth,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });
}

/// Implementation of NetworkService
class NetworkServiceImpl implements NetworkService {
  final void Function()? onLogout;
  final String? appType;
  late final Dio _client;
  final List<CancelToken> _pendingRequests = [];
  final Map<String, NetworkRequest> _allRequests = {};

  NetworkServiceImpl({required this.onLogout, this.appType}) {
    _client = _createDioClient();
  }

  String _generateRequestId(NetworkRequest request) {
    dynamic body;

    if (request.data is FormData) {
      final formData = request.data as FormData;
      body = {
        for (var field in formData.fields) field.key: field.value,
        for (var file in formData.files) file.key: file.value.filename,
      };
    } else {
      body = request.data ?? {};
    }

    final dataString = jsonEncode({
      'method': request.method.toString(),
      'url': request.url,
      'headers': request.headers ?? {},
      'queryParameters': request.queryParameters ?? {},
      'body': body,
    });

    final bytes = utf8.encode(dataString);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  Dio _createDioClient() => Dio(
      BaseOptions(
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )
    ..interceptors.addAll([
      AppInfoInterceptor(appInfoService: sl(), deviceInfoService: sl()),
      AuthInterceptor(
        pendingRequests: _pendingRequests,
        cacheService: sl(),
        onLogout: onLogout,
      ),
      LanguageInterceptor(cacheService: sl()),
      AppTypeInterceptor(appType: appType),
      RequestsInspectorInterceptor(),
    ]);

  @override
  Future<Response> execute(NetworkRequest request) async {
    final mergedHeaders = {
      ...getDefaultHeaders(),
      if (request.headers != null) ...request.headers!,
    };
    request.cancelToken ??= CancelToken();
    final requestId = _generateRequestId(request);

    if (_allRequests.containsKey(requestId)) {
      throw Exception('Duplicated request id: $requestId');
    }
    _allRequests[requestId] = request;
    _pendingRequests.add(request.cancelToken!);

    try {
      final response = await _performRequest(
        request.method,
        request.url,
        data: request.data,
        queryParameters: request.queryParameters,
        headers: mergedHeaders,
        responseType: request.responseType,
        skipAuth: request.skipAuth,
        cancelToken: request.cancelToken!,
      );
      return response;
    } on DioException catch (e) {
      logger.error('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      logger.error('Unexpected error: $e');
      rethrow;
    } finally {
      _pendingRequests.remove(request.cancelToken!);
      _allRequests.remove(requestId);
    }
  }

  Future<Response> _performRequest(
    HttpMethod method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    required CancelToken cancelToken,
  }) {
    final options = Options(
      headers: headers,
      responseType: responseType,
      extra: skipAuth ? {"skipAuth": true} : null,
    );

    switch (method) {
      case HttpMethod.get:
        return _client.get(
          url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.post:
        return _client.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.patch:
        return _client.patch(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.put:
        return _client.put(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      case HttpMethod.delete:
        return _client.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
    }
  }

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    CancelToken? cancelToken,
  }) => execute(
    NetworkRequest(
      method: HttpMethod.get,
      url: url,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      skipAuth: skipAuth,
      cancelToken: cancelToken,
    ),
  );

  @override
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    CancelToken? cancelToken,
  }) => execute(
    NetworkRequest(
      method: HttpMethod.post,
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      skipAuth: skipAuth,
      cancelToken: cancelToken,
    ),
  );

  @override
  Future<Response> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    CancelToken? cancelToken,
  }) => execute(
    NetworkRequest(
      method: HttpMethod.patch,
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      skipAuth: skipAuth,
      cancelToken: cancelToken,
    ),
  );

  @override
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    CancelToken? cancelToken,
  }) => execute(
    NetworkRequest(
      method: HttpMethod.put,
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      skipAuth: skipAuth,
      cancelToken: cancelToken,
    ),
  );

  @override
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool skipAuth = false,
    CancelToken? cancelToken,
  }) => execute(
    NetworkRequest(
      method: HttpMethod.delete,
      url: url,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      skipAuth: skipAuth,
      cancelToken: cancelToken,
    ),
  );

  @override
  Future<Response> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool skipAuth = false,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final mergedHeaders = {
      ...getDefaultHeaders(),
      if (headers != null) ...headers,
    };

    final token = cancelToken ?? CancelToken();
    _pendingRequests.add(token);

    try {
      final options = Options(
        headers: mergedHeaders,
        extra: skipAuth ? {"skipAuth": true} : null,
      );

      final response = await _client.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: token,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      logger.error('Download DioException: ${e.message}');
      rethrow;
    } catch (e) {
      logger.error('Download unexpected error: $e');
      rethrow;
    } finally {
      _pendingRequests.remove(token);
    }
  }

  /// Default headers for every request
  Map<String, dynamic> getDefaultHeaders() => {
    'Content-Type': 'application/json',
  };
}
