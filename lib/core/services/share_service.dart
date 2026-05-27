import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

abstract class ShareService {
  Future<void> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  });

  /// Convenience: derives the position origin from a [BuildContext] so iPad
  /// share sheets anchor near the tapped widget.
  Future<void> shareFrom({
    required BuildContext context,
    required String text,
    String? subject,
  });
}

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  @override
  Future<void> shareFrom({
    required BuildContext context,
    required String text,
    String? subject,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await shareText(
      text: text,
      subject: subject,
      sharePositionOrigin: origin,
    );
  }
}
