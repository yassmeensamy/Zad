import 'package:dio/dio.dart';

import '../services/app_info_service.dart';
import '../services/device_info_service.dart';

class AppInfoInterceptor extends Interceptor {
  final AppInfoService _appInfoService;
  final DeviceInfoService _deviceInfoService;

  AppInfoInterceptor({
    required AppInfoService appInfoService,
    required DeviceInfoService deviceInfoService,
  }) : _appInfoService = appInfoService,
       _deviceInfoService = deviceInfoService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final appInfo = await _appInfoService.getAppInfo();
    final deviceId = await _deviceInfoService.getDeviceID();
    options.headers.addAll({
      'User-Agent': 'eram-app/$appInfo.version',
      if (deviceId != null) 'deviceId': deviceId,
    });

    super.onRequest(options, handler);
  }
}
