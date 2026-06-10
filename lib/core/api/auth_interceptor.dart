import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_app/core/utils/logger.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:sentry_dio/sentry_dio.dart';

import '../constants/storage_keys.dart';
import '../expections/session_expire_expection.dart';
import '../models/token_model.dart';
import '../services/cache_service.dart';
import 'endpoints/app_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required CacheService cacheService,
    required AppEndpoint endpoints,
    required this.onLogout,
    required this.pendingRequests,
  }) : _cacheService = cacheService,
       _endpoints = endpoints;

  final void Function()? onLogout;
  final CacheService _cacheService;
  final AppEndpoint _endpoints;
  final List<CancelToken> pendingRequests;
  Completer<TokensModel?>? _refreshCompleter;

  final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl:  "https://zaad-app.com/",
            validateStatus: (_) => true,
          ),
        )
        ..interceptors.addAll([
          // Debug-only network inspector; release builds tree-shake it out.
          if (kDebugMode) RequestsInspectorInterceptor(),
        ])
        // Sentry breadcrumbs + spans + failed-request capture for the
        // token-refresh / retry traffic. Headers/body are scrubbed in the
        // app's `beforeSend`. Added LAST so it observes the final request.
        ..addSentry();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _cacheService.get<String>(
        StorageKeys.kAccessTokenKey,
        isSecure: true,
      );
      if (options.extra['skipAuth'] == true || token == null) {
        return handler.next(options);
      }
      if (!JwtDecoder.isExpired(token)) {
        _setAuthHeader(options, token);
        return handler.next(options);
      }
      final newTokens = await _refreshAccessToken(options.cancelToken);
      if (newTokens == null) return _logoutAndReject(options, handler);
      _setAuthHeader(options, newTokens.access);
      handler.next(options);
    } on SessionExpiredException {
      return _logoutAndReject(options, handler);
    } on Object catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_needsRefresh(response)) {
      try {
        final newTokens = await _refreshAccessToken(
          response.requestOptions.cancelToken,
        );
        if (newTokens == null) return _logoutAndReject(response, handler);

        final retried = await _retryRequest(
          response.requestOptions,
          newTokens.access,
        );
        // A retry that *still* comes back 401/403 means the (just-refreshed)
        // token is genuinely rejected by the server — treat it as a dead
        // session and log out, rather than resolving the 401 body up to the
        // caller (which would surface as a raw ServerException).
        if (retried == null || _isAuthFailure(retried.statusCode)) {
          return _logoutAndReject(response, handler);
        }
        return handler.resolve(retried);
      } on SessionExpiredException {
        return _logoutAndReject(response, handler);
      } on DioException catch (e) {
        return handler.reject(e);
      } on Object catch (e) {
        return handler.reject(
          DioException(requestOptions: response.requestOptions, error: e),
        );
      }
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.type == DioExceptionType.cancel) {
      logger.debug('Request cancelled: ${err.requestOptions.path}');
    }
    handler.next(err);
  }

  // ---------------------- Helpers ----------------------

  bool _needsRefresh(Response<dynamic> response) {
    final hadAuth = response.requestOptions.headers.containsKey(
      'Authorization',
    );
    return _isAuthFailure(response.statusCode) && hadAuth;
  }

  bool _isAuthFailure(int? statusCode) =>
      statusCode == 401 || statusCode == 403;

  void _setAuthHeader(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
  }

  Future<TokensModel?> _refreshAccessToken([CancelToken? cancelToken]) {
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<TokensModel?>();
    _refreshCompleter = completer;
    unawaited(_runRefresh(completer, cancelToken));
    return completer.future;
  }

  Future<void> _runRefresh(
    Completer<TokensModel?> completer,
    CancelToken? cancelToken,
  ) async {
    try {
      logger.debug('Refreshing access token');
      final refreshToken = await _cacheService.get<String>(
        StorageKeys.kRefreshTokenKey,
        isSecure: true,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        throw SessionExpiredException('No refresh token found');
      }

      final res = await _dio.post<dynamic>(
        _endpoints.refresh,
        data: {'refresh': refreshToken},
        cancelToken: cancelToken,
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final tokens = TokensModel.fromMap(res.data as Map<String, dynamic>);
        await _saveTokens(tokens);
        completer.complete(tokens);
        return;
      }

      throw SessionExpiredException('Token refresh failed');
    } on Object catch (e) {
      completer.completeError(e);
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>?> _retryRequest(
    RequestOptions original,
    String token,
  ) async {
    if (original.cancelToken?.isCancelled == true) return null;

    final newOptions = _cloneRequestOptions(original);
    _setAuthHeader(newOptions, token);

    try {
      return await _dio.fetch(newOptions);
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<void> _saveTokens(TokensModel tokens) async {
    await _cacheService.set(
      StorageKeys.kAccessTokenKey,
      tokens.access,
      isSecure: true,
    );
    await _cacheService.set(
      StorageKeys.kRefreshTokenKey,
      tokens.refresh,
      isSecure: true,
    );
    logger.debug('Tokens saved');
  }

  void _logoutAndReject(dynamic requestOrResponse, Object handler) {
    try {
      _cancelAllPending();
      unawaited(
        _clearDataAndNavigate().catchError(
          (Object e) => logger.error('Logout cleanup failed: $e'),
        ),
      );

      final requestOptions = requestOrResponse is Response
          ? requestOrResponse.requestOptions
          : requestOrResponse as RequestOptions;

      final exception = DioException(
        requestOptions: requestOptions,
        error: 'session_expired',
      );

      if (handler is RequestInterceptorHandler) {
        handler.reject(exception);
      } else if (handler is ResponseInterceptorHandler) {
        handler.reject(exception);
      } else {
        throw ArgumentError.value(
          handler,
          'handler',
          'Unsupported handler type',
        );
      }
    } on Object catch (e) {
      logger.error('_logoutAndReject failed: $e');
    }
  }

  void _cancelAllPending() {
    for (final token in pendingRequests) {
      if (!token.isCancelled) {
        token.cancel('Logout - cancelling request');
      }
    }
    pendingRequests.clear();
  }

  Future<void> _clearDataAndNavigate() async {
    await _navigateToLogin();
    logger.debug('Navigate to login');
  }

  RequestOptions _cloneRequestOptions(RequestOptions from) {
    final data = from.data is FormData
        ? _cloneFormData(from.data as FormData)
        : from.data;
    return RequestOptions(
      method: from.method,
      path: from.path,
      baseUrl: from.baseUrl,
      data: data,
      queryParameters: from.queryParameters,
      headers: Map.from(from.headers),
      responseType: from.responseType,
      contentType: from.contentType,
      cancelToken: from.cancelToken,
      extra: from.extra,
    );
  }

  FormData _cloneFormData(FormData src) {
    final copy = FormData();
    copy.fields.addAll(src.fields);
    copy.files.addAll(src.files);
    return copy;
  }

  Future<void> _navigateToLogin() async {
    await _cacheService.clearAll(isSecure: true);
    onLogout?.call();
    logger.debug('Logout triggered');
  }
}
