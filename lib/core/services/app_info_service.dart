import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_info_model.dart';

abstract class AppInfoService {
  Future<AppInfoModel> getAppInfo();
}

class AppInfoServiceImpl implements AppInfoService {
  AppInfoModel? _appInfo;
  @override
  Future<AppInfoModel> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    _appInfo = AppInfoModel(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );

    return _appInfo!;
  }
}
