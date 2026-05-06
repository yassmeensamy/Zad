import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../cubit/edit_profile_form_cubit.dart';
import '../cubit/edit_profile_form_state.dart';
import '../widgets/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserCubit>().state.user;
    return BlocProvider<EditProfileFormCubit>(
      lazy: false,
      create: (_) {
        final cubit = EditProfileFormCubit();
        if (user != null) cubit.init(user);
        return cubit;
      },
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final updated = context.read<EditProfileFormCubit>().state.updatedUser;
    if (updated == null) return;
    context.read<UserCubit>().updateProfile(
      fullName: updated.fullName.trim(),
      birthDate: updated.birthDate,
    );
  }

  Future<void> _confirmDelete() async {
    await CustomDialog.show<void>(
      context: context,
      barrierDismissible: false,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: const _DeletePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZaadAppBar(
        title: 'profile.edit_profile',
        onBack: context.canPop() ? () => context.pop() : null,
      ),
      body: BlocListener<UserCubit, UserState>(
        listenWhen: (a, b) => a.updateStatus != b.updateStatus,
        listener: (context, state) {
          if (state.isUpdateSuccess) {
            SnackBarHelper.showSuccess(
              context,
              message: 'edit_profile.update_success',
            );
            context.read<UserCubit>().resetUpdateStatus();
          } else if (state.isUpdateError) {
            SnackBarHelper.showError(
              context,
              message: state.updateErrorMessage ?? 'edit_profile.update_failed',
            );
            context.read<UserCubit>().resetUpdateStatus();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EditProfileForm(),
                  const SizedBox(height: 24),
                  _SaveButton(onTap: _onSave),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (a, b) => a.status != b.status,
                    builder: (context, state) {
                      return _DeleteAccountCard(
                        onDelete: state.isLoading ? null : _confirmDelete,
                      );
                    },
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (a, b) => a.user != b.user || a.updateStatus != b.updateStatus,
      builder: (context, userState) {
        return BlocSelector<EditProfileFormCubit, EditProfileFormState, bool>(
          selector: (state) => state.isDirtyAgainst(userState.user),
          builder: (context, isDirty) {
            return AuthPrimaryButton(
              label: 'common.save',
              enabled: isDirty,
              onTap: onTap,
            );
          },
        );
      },
    );
  }
}


class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard({required this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final disabled = onDelete == null;
    final tint = errorColor.withValues(alpha: disabled ? 0.4 : 1);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderDefault, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveText(
              'edit_profile.delete_account',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: tint,
              ),
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              'edit_profile.delete_account_description',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.5,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.borderDefault, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: tint,
                      ),
                      const SizedBox(width: 10),
                      ResponsiveText(
                        'edit_profile.delete_account_cta',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.16,
                          color: tint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.eyebrowKey,
    required this.titleLeadKey,
    required this.titleAccentKey,
    this.danger = false,
  });

  final String eyebrowKey;
  final String titleLeadKey;
  final String titleAccentKey;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    final eyebrowColor = danger
        ? errorColor.withValues(alpha: 0.85)
        : colors.oliveSoft;
    final accentColor = danger ? errorColor : colors.textArabic;
    final ruleColor = danger ? errorColor : colors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ResponsiveText(
            eyebrowKey,
            textAlign: TextAlign.center,
            style: ZaadType.eyebrowSm.copyWith(color: eyebrowColor),
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
                      color: accentColor,
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
            color: ruleColor,
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


class _DeletePasswordDialog extends StatefulWidget {
  const _DeletePasswordDialog();

  @override
  State<_DeletePasswordDialog> createState() => _DeletePasswordDialogState();
}

class _DeletePasswordDialogState extends State<_DeletePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _serverError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _serverError = null);
    context.read<AuthCubit>().deleteAccount(_controller.text);
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state.isNotLoggedIn) {
      Navigator.of(context).pop();
      context.goNamed(AppRoutes.loginName);
    } else if (state.isError) {
      setState(() => _serverError = state.errorMessage);
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'edit_profile.delete_password_required'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = context.colorScheme.error;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onAuthState,
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          final loading = state.isLoading;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _DialogHeader(
                      eyebrowKey: 'edit_profile.delete_password_eyebrow',
                      titleLeadKey: 'edit_profile.delete_password_title_lead',
                      titleAccentKey:
                          'edit_profile.delete_password_title_accent',
                      danger: true,
                    ),
                    const SizedBox(height: 14),
                    _PwdField(
                      controller: _controller,
                      labelKey: 'edit_profile.delete_password_label',
                      hintKey: 'edit_profile.delete_password_hint',
                      enabled: !loading,
                      textInputAction: TextInputAction.done,
                      errorText: _serverError?.tr(),
                      onChanged: (_) {
                        if (_serverError != null) {
                          setState(() => _serverError = null);
                        }
                      },
                      onSubmitted: (_) => _submit(),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: errorColor.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ResponsiveText(
                              'edit_profile.delete_password_helper',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 11,
                                height: 1.5,
                                letterSpacing: 0,
                                color: errorColor.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ZaadPrimaryButton(
                      label: 'edit_profile.delete_password_cta',
                      loading: loading,
                      onTap: _submit,
                      variant: ZaadButtonVariant.danger,
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
