import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_close_button.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _serverError;
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    _newController.addListener(_recomputeStrength);
  }

  @override
  void dispose() {
    _newController.removeListener(_recomputeStrength);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _recomputeStrength() {
    final v = _newController.text;
    var score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    if (score != _strength) setState(() => _strength = score);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _serverError = null);
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
      setState(() => _serverError = state.changePasswordErrorMessage);
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
                    const SizedBox(height: 14),
                    _PwdField(
                      controller: _currentController,
                      labelKey: 'edit_profile.current_password_label',
                      hintKey: 'edit_profile.current_password_hint',
                      enabled: !loading,
                      textInputAction: TextInputAction.next,
                      errorText: _serverError?.tr(),
                      onChanged: (_) {
                        if (_serverError != null) {
                          setState(() => _serverError = null);
                        }
                      },
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 10),
                    _PwdField(
                      controller: _newController,
                      labelKey: 'edit_profile.new_password_label',
                      hintKey: 'edit_profile.new_password_hint',
                      enabled: !loading,
                      textInputAction: TextInputAction.next,
                      validator: _validateNew,
                    ),
                    const SizedBox(height: 8),
                    _StrengthBars(score: _strength),
                    const SizedBox(height: 10),
                    _PwdField(
                      controller: _confirmController,
                      labelKey: 'edit_profile.confirm_password_label',
                      hintKey: 'edit_profile.confirm_password_hint',
                      enabled: !loading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: _validateConfirm,
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
                child: ZaadCloseButton(
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

class _PwdField extends StatefulWidget {
  const _PwdField({
    required this.controller,
    required this.labelKey,
    required this.hintKey,
    required this.enabled,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final String labelKey;
  final String hintKey;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  @override
  State<_PwdField> createState() => _PwdFieldState();
}

class _PwdFieldState extends State<_PwdField> {
  bool _obscure = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final focused = _focusNode.hasFocus;
    final errorColor = context.colorScheme.error;

    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (formState) {
        final showError = hasError || formState.hasError;
        final errorMessage = widget.errorText ?? formState.errorText;

        Color borderColor;
        if (showError) {
          borderColor = errorColor.withValues(alpha: 0.6);
        } else if (focused) {
          borderColor = colors.olive;
        } else {
          borderColor = colors.olive.withValues(alpha: 0.18);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.canvas,
                borderRadius: BorderRadius.circular(ZaadRadii.md),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: focused && !showError
                    ? [
                        BoxShadow(
                          color: colors.olive.withValues(alpha: 0.08),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          widget.labelKey,
                          style: ZaadType.fieldLabel.copyWith(
                            color: colors.oliveSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          enabled: widget.enabled,
                          obscureText: _obscure,
                          obscuringCharacter: '•',
                          textInputAction: widget.textInputAction,
                          onChanged: (v) {
                            widget.onChanged?.call(v);
                            formState.didChange(v);
                          },
                          onSubmitted: widget.onSubmitted,
                          style: AppTextStyles.labelLarge.copyWith(
                            letterSpacing: 0,
                            color: colors.oliveDeep,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: widget.hintKey.tr(),
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textSecondary
                                  .withValues(alpha: 0.7),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.enabled
                        ? () => setState(() => _obscure = !_obscure)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16,
                        color: colors.oliveSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showError && errorMessage != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  errorMessage,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    color: errorColor,
                  ),
                ),
              ),
            ],
          ],
        );
      },
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

