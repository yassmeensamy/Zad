import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:requests_inspector/requests_inspector.dart';

import '../constants/storage_keys.dart';
import '../expections/session_expire_expection.dart';
import '../models/token_model.dart';
import '../services/cache_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required CacheService cacheService,
    required this.onLogout,
    required this.pendingRequests,
  }) : _cacheService = cacheService;

  final void Function()? onLogout;
  final CacheService _cacheService;
  final List<CancelToken> pendingRequests;
  Completer<TokensModel?>? _refreshCompleter;

  final Dio _dio = Dio(BaseOptions(validateStatus: (_) => true))
    ..interceptors.add(RequestsInspectorInterceptor());

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
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  Future<void> onResponse(
    Response response,
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
        return retried != null
            ? handler.resolve(retried)
            : _logoutAndReject(response, handler);
      } on SessionExpiredException {
        return _logoutAndReject(response, handler);
      } on DioException catch (e) {
        return handler.reject(e);
      } catch (e) {
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: e,
            type: DioExceptionType.unknown,
          ),
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

  bool _needsRefresh(Response response) {
    final status = response.statusCode;
    final hadAuth = response.requestOptions.headers.containsKey(
      'Authorization',
    );
    return (status == 401 || status == 403) && hadAuth;
  }

  void _setAuthHeader(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
  }

  Future<TokensModel?> _refreshAccessToken([CancelToken? cancelToken]) async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    logger.debug('Refreshing access token');
    _refreshCompleter = Completer<TokensModel?>();
    final refreshToken = await _cacheService.get<String>(
      StorageKeys.kRefreshTokenKey,
      isSecure: true,
    );

    if (refreshToken == null || refreshToken.isEmpty) {
      final error = SessionExpiredException('No refresh token found');
      _completeRefreshError(error);
      throw error;
    }

    try {
      final res = await _dio.post(
        'https://template.eramapps.com/api/refresh-token/',
        data: {'refresh': refreshToken},
        cancelToken: cancelToken,
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final tokens = TokensModel.fromMap(res.data);
        await _saveTokens(tokens);
        _completeRefresh(tokens);
        return tokens;
      }

      final error = SessionExpiredException('Token refresh failed');
      _completeRefreshError(error);
      throw error;
    } on DioException catch (e) {
      _completeRefreshError(e);
      rethrow;
    } catch (e) {
      _completeRefreshError(e);
      rethrow;
    }
  }

  Future<Response?> _retryRequest(RequestOptions original, String token) async {
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

  void _completeRefresh(Object? result) {
    _refreshCompleter?.complete(result as TokensModel?);
    _refreshCompleter = null;
  }

  void _completeRefreshError(Object error) {
    _refreshCompleter?.completeError(error);
    _refreshCompleter = null;
  }

  void _logoutAndReject(dynamic requestOrResponse, dynamic handler) {
    _cancelAllPending();
    _clearDataAndNavigate();

    final requestOptions =
        requestOrResponse is Response
            ? requestOrResponse.requestOptions
            : requestOrResponse as RequestOptions;

    handler.reject(
      DioException(requestOptions: requestOptions, error: 'session_expired'),
    );
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
    final data =
        from.data is FormData
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
