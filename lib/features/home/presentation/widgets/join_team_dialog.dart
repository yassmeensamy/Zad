import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/theme.dart';

/// Modal that asks the user to enter a team code so they can join the team
/// from the [JoinTeamCard]. Returns the trimmed code via `Navigator.pop` when
/// the CTA is pressed, or `null` if dismissed.
Future<String?> showJoinTeamDialog(BuildContext context) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'home.team.modal.title_accent'.tr(),
    barrierColor: AppColors.shadowDeep.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, _, _) => const _JoinTeamDialog(),
    transitionBuilder: (context, anim, _, child) {
      final scale = Tween(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
      );
      return Opacity(
        opacity: anim.value,
        child: Transform.scale(scale: scale.value, child: child),
      );
    },
  );
}

class _JoinTeamDialog extends StatefulWidget {
  const _JoinTeamDialog();

  @override
  State<_JoinTeamDialog> createState() => _JoinTeamDialogState();
}

class _JoinTeamDialogState extends State<_JoinTeamDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.creamSurfaceTop, colors.creamSurfaceBottom],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.olive.withValues(alpha: 0.20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.35),
                    blurRadius: 60,
                    offset: const Offset(0, 28),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DialogHeader(),
                      const SizedBox(height: 14),
                      _CodeField(controller: _controller),
                      const SizedBox(height: 10),
                      _SubmitButton(
                        onTap: () {
                          final code = _controller.text.trim();
                          Navigator.of(context).pop(
                            code.isEmpty ? null : code,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned(
      top: -10,
      right: -10,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.cardSurface,
              border: Border.all(
                color: colors.olive.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: colors.oliveDeep,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text(
          'home.team.modal.eyebrow'.tr().toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 9 * 0.34,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 24,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'home.team.modal.title_prefix'.tr()),
              TextSpan(
                text: 'home.team.modal.title_accent'.tr(),
                style: TextStyle(color: colors.textArabic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 24, height: 1, color: colors.accent),
      ],
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.22),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.team.modal.code_label'.tr().toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 9 * 0.32,
              color: colors.oliveSoft,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLength: 9,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              _UpperCaseFormatter(),
            ],
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '',
              filled: false,
              hintText: 'home.team.modal.code_placeholder'.tr(),
              hintStyle: AppTextStyles.titleLarge.copyWith(
                letterSpacing: 18 * 0.18,
                color: colors.oliveSoft.withValues(alpha: 0.35),
              ),
            ),
            style: AppTextStyles.titleLarge.copyWith(
              letterSpacing: 18 * 0.18,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
              colors: [colors.oliveSoft, colors.olive, colors.oliveDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.oliveDeep.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'home.team.modal.submit'.tr().toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 11 * 0.18,
              color: colors.canvas,
            ),
          ),
        ),
      ),
    );
  }
}
