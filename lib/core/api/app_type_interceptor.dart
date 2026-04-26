import 'package:dio/dio.dart';

class AppTypeInterceptor extends Interceptor {
  final String? appType;

  AppTypeInterceptor({this.appType});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appType != null) {
      options.headers.addAll({'X-App-Type': appType});
    }
    super.onRequest(options, handler);
  }
}
