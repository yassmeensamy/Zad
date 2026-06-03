import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';


class OtpTimer extends StatefulWidget {
  const OtpTimer({
    super.key,
    this.duration = 60,
    required this.onResend,
    required this.baseTextStyle,
    required this.linkTextStyle,
    this.disabledLinkTextStyle,
    this.direction = Axis.horizontal,
    this.spacing = 4.0,
  });

  final int duration;
  final VoidCallback onResend;
  final TextStyle baseTextStyle;
  final TextStyle linkTextStyle;
  final TextStyle? disabledLinkTextStyle;
  final Axis direction;
  final double spacing;

  @override
  State<OtpTimer> createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  bool get _isCounting => _remainingSeconds > 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration;
    _startCountdown();
  }

  @override
  void didUpdateWidget(OtpTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _remainingSeconds = widget.duration;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _handleResend() {
    widget.onResend();
    _remainingSeconds = widget.duration;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resendText = _isCounting
        ? '${"resend_in".tr()} ($_remainingSeconds ${"seconds".tr()})'
        : 'resend'.tr();

    final didNotReceiveText = ResponsiveText(
      'did_not_receive_code'.tr(),
      style: widget.baseTextStyle,
    );

    final disabledStyle =
        widget.disabledLinkTextStyle ??
        widget.linkTextStyle.copyWith(
          color: widget.linkTextStyle.color?.withValues(alpha: 0.5),
        );

    final resendLink = GestureDetector(
      onTap: _isCounting ? null : _handleResend,
      child: ResponsiveText(
        resendText,
        style: _isCounting ? disabledStyle : widget.linkTextStyle,
      ),
    );

    return Center(
      child: widget.direction == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                didNotReceiveText,
                SizedBox(height: widget.spacing),
                resendLink,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                didNotReceiveText,
                SizedBox(width: widget.spacing),
                resendLink,
              ],
            ),
    );
  }
}
