import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_links.dart';
import '../services/core_service_locator.dart';
import '../services/share_service.dart';

/// Opens the share sheet with the app's own store listings.
///
/// Both store links go out every time: the share sheet has no idea what the
/// recipient is holding, so whoever gets the message picks their own.
///
/// [context] should be the widget that was tapped — iPad anchors the share
/// popover to its bounds.
Future<void> shareApp(BuildContext context) {
  return sl<ShareService>().shareFrom(
    context: context,
    text: 'share.message'.tr(
      namedArgs: {
        'app': 'app_name'.tr(),
        'ios': AppLinks.appStore,
        'android': AppLinks.playStore,
      },
    ),
    subject: 'share.subject'.tr(namedArgs: {'app': 'app_name'.tr()}),
  );
}
