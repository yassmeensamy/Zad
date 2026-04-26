import '../utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final timezone = timezoneInfo.identifier;
    logger.debug('Adding timezone to headers: $timezone');
    options.headers.addAll({'X-Timezone': timezone});
    super.onRequest(options, handler);
  }
}
