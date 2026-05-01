import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/support_request_model.dart';

/// Replaces the form once a request has been accepted. The card opens with
/// a soft scale-and-fade so the screen feels like it exhales after sending.
class HelpSuccessCard extends StatelessWidget {
  const HelpSuccessCard({
    super.key,
    required this.request,
    required this.onSendAnother,
    required this.onClose,
  });

  final SupportRequestModel request;
  final VoidCallback onSendAnother;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = request.topic.accent(colors);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: Transform.scale(
            scale: 0.96 + 0.04 * t,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.canvas.withValues(alpha: 0.96),
              colors.canvasRaised.withValues(alpha: 0.82),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.olive.withValues(alpha: 0.14),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.oliveDeep.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            _SealMark(accent: accent),
            const SizedBox(height: 22),
            ResponsiveText(
              'help_center.success.title',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: 0,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveText(
              'help_center.success.subtitle',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                height: 1.55,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _ReceiptRow(
              labelKey: 'help_center.success.topic_label',
              value: request.topic.label,
              accent: accent,
            ),
            const SizedBox(height: 12),
            _ReceiptRow(
              labelKey: 'help_center.success.reference_label',
              value: '#${request.id?.toString().padLeft(4, '0') ?? '----'}',
              accent: accent,
              isRaw: true,
            ),
            const SizedBox(height: 32),
            CustomButton.full(
              onTap: onSendAnother,
              theme: CustomButtonTheme(
                height: 50,
                backgroundColor: colors.olive,
                textColor: colors.canvas,
                borderRadius: 14,
              ),
              child: ResponsiveText(
                'help_center.success.send_another',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  color: colors.canvas,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClose,
              child: ResponsiveText(
                'help_center.success.close',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SealMark extends StatelessWidget {
  const _SealMark({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            accent.withValues(alpha: 0.0),
          ],
          radius: 0.85,
        ),
      ),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, accent.withValues(alpha: 0.78)],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colors.canvas,
          size: 26,
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.labelKey,
    required this.value,
    required this.accent,
    this.isRaw = false,
  });

  final String labelKey;
  final String value;
  final Color accent;

  /// When true, [value] is rendered as-is (e.g. a reference number) instead
  /// of being passed through translation.
  final bool isRaw;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(ZaadRadii.md),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ResponsiveText(
              labelKey,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: colors.textSecondary,
              ),
            ),
          ),
          if (isRaw)
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: colors.oliveDeep,
              ),
            )
          else
            ResponsiveText(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: colors.oliveDeep,
              ),
            ),
        ],
      ),
    );
  }
}
