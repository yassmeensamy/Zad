import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/zaad_text_field.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';

class ChangePasswordDialog {
  const ChangePasswordDialog._();

  static Future<void> show(BuildContext context) {
    return CustomDialog.show<void>(
      context: context,
      barrierDismissible: false,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: const _ChangePasswordDialog(),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  late final ValueNotifier<String?> _serverError;
  late final ValueNotifier<int> _strength;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
    _serverError = ValueNotifier<String?>(null);
    _strength = ValueNotifier<int>(0);
    _newController.addListener(_recomputeStrength);
  }

  @override
  void dispose() {
    _newController.removeListener(_recomputeStrength);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _serverError.dispose();
    _strength.dispose();
    super.dispose();
  }

  void _recomputeStrength() {
    final v = _newController.text;
    var score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    if (score != _strength.value) _strength.value = score;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _serverError.value = null;
    context.read<UserCubit>().changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      confirmNewPassword: _confirmController.text,
    );
  }

  void _onUserState(BuildContext context, UserState state) {
    if (state.isPasswordSuccess) {
      Navigator.of(context).pop();
      SnackBarHelper.showSuccess(
        context,
        message: 'edit_profile.change_password_success',
      );
      context.read<UserCubit>().resetChangePasswordStatus();
    } else if (state.isPasswordError) {
      _serverError.value = state.changePasswordErrorMessage;
      context.read<UserCubit>().resetChangePasswordStatus();
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'edit_profile.password_required'.tr();
    }
    return null;
  }

  String? _validateNew(String? value) {
    final required = _validateRequired(value);
    if (required != null) return required;
    if (value!.length < 8) {
      return 'edit_profile.password_min_length'.tr();
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final required = _validateRequired(value);
    if (required != null) return required;
    if (value != _newController.text) {
      return 'edit_profile.password_mismatch'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<UserCubit, UserState>(
      listenWhen: (a, b) => a.changePasswordStatus != b.changePasswordStatus,
      listener: _onUserState,
      child: BlocBuilder<UserCubit, UserState>(
        buildWhen: (a, b) => a.changePasswordStatus != b.changePasswordStatus,
        builder: (context, state) {
          final loading = state.isPasswordLoading;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DialogHeader(
                      eyebrowKey: 'edit_profile.change_password_eyebrow',
                      titleLeadKey: 'edit_profile.change_password_title_lead',
                      titleAccentKey:
                          'edit_profile.change_password_title_accent',
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<String?>(
                      valueListenable: _serverError,
                      builder: (context, serverError, _) {
                        return ZaadTextField(
                          hintText: 'edit_profile.current_password_hint',
                          controller: _currentController,
                          enabled: !loading,
                          obscureText: true,
                          passwordToggle: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.next,
                          errorText: serverError?.tr(),
                          onChanged: (_) {
                            if (_serverError.value != null) {
                              _serverError.value = null;
                            }
                          },
                          validator: _validateRequired,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colors.oliveSoft,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ZaadTextField(
                      hintText: 'edit_profile.new_password_hint',
                      controller: _newController,
                      enabled: !loading,
                      obscureText: true,
                      passwordToggle: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: _validateNew,
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        color: colors.oliveSoft,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _strength,
                      builder: (context, strength, _) =>
                          _StrengthBars(score: strength),
                    ),
                    const SizedBox(height: 12),
                    ZaadTextField(
                      hintText: 'edit_profile.confirm_password_hint',
                      controller: _confirmController,
                      enabled: !loading,
                      obscureText: true,
                      passwordToggle: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _validateConfirm,
                      prefixIcon: Icon(
                        Icons.check_circle_outline_rounded,
                        color: colors.oliveSoft,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ResponsiveText(
                        'edit_profile.change_password_helper',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 11,
                          height: 1.5,
                          letterSpacing: 0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ZaadPrimaryButton(
                      label: 'edit_profile.change_password_cta',
                      loading: loading,
                      onTap: _submit,
                      height: 46,
                      borderRadius: ZaadRadii.md,
                      fontSize: 12,
                      letterSpacing: 2.16,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: ZaadCircleIconButton.close(
                  enabled: !loading,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.eyebrowKey,
    required this.titleLeadKey,
    required this.titleAccentKey,
  });

  final String eyebrowKey;
  final String titleLeadKey;
  final String titleAccentKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ResponsiveText(
            eyebrowKey,
            textAlign: TextAlign.center,
            style: ZaadType.eyebrowSm.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: ZaadType.titleAccent.copyWith(color: colors.oliveDeep),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${titleLeadKey.tr()} '),
                  TextSpan(
                    text: titleAccentKey.tr(),
                    style: AppTextStyles.titleLarge.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colors.textArabic,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 28,
            height: 1,
            color: colors.accent,
          ),
        ],
      ),
    );
  }
}

class _StrengthBars extends StatelessWidget {
  const _StrengthBars({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(4, (i) {
          final on = i < score;
          return Expanded(
            child: Container(
              margin: EdgeInsetsDirectional.only(end: i == 3 ? 0 : 4),
              height: 3,
              decoration: BoxDecoration(
                color: on
                    ? colors.olive
                    : colors.olive.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

