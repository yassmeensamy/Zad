import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

abstract class DeviceInfoService {
  Future<String?> getDeviceID();
}

class DeviceInfoServiceImpl implements DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  Future<String?> getDeviceID() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      String deviceId = androidInfo.id;
      return deviceId;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      final String? deviceId = iosInfo.identifierForVendor;
      return deviceId;
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
}
