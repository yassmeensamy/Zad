import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/textforms/main_text_form.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zad_app_bar.dart';
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
      child: const _DeletePasswordDialog(),
    );
  }

  Future<void> _openChangePassword() async {
    await CustomDialog.show<void>(
      context: context,
      barrierDismissible: false,
      child: const _ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ZadAppBar(
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
                  const SizedBox(height: 12),
                  _ChangePasswordTile(onTap: _openChangePassword),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (a, b) => a.status != b.status,
                    builder: (context, state) {
                      final errorColor = context.colorScheme.error;
                      return Center(
                        child: TextButton.icon(
                          onPressed: state.isLoading ? null : _confirmDelete,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: errorColor,
                          ),
                          label: ResponsiveText(
                            'edit_profile.delete_account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: errorColor,
                              decoration: TextDecoration.underline,
                              decorationColor: errorColor,
                            ),
                          ),
                        ),
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

class _ChangePasswordTile extends StatelessWidget {
  const _ChangePasswordTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colors.canvas,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.20),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_reset_rounded,
                size: 20,
                color: colors.oliveDeep,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText(
                  'edit_profile.change_password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.oliveDeep,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.olive.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
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

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
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
        buildWhen: (a, b) =>
            a.changePasswordStatus != b.changePasswordStatus,
        builder: (context, state) {
          final loading = state.isPasswordLoading;
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.olive.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: colors.oliveDeep,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                ResponsiveText(
                  'edit_profile.change_password_title',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.oliveDeep,
                  ),
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'edit_profile.change_password_subtitle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                MainTextFormField(
                  controller: _currentController,
                  hintText: 'edit_profile.current_password_hint'.tr(),
                  obscureText: true,
                  passwordToggle: true,
                  isEnabled: !loading,
                  textInputAction: TextInputAction.next,
                  errorText: _serverError?.tr(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (_) {
                    if (_serverError != null) {
                      setState(() => _serverError = null);
                    }
                  },
                  validator: _validateRequired,
                ),
                const SizedBox(height: 12),
                MainTextFormField(
                  controller: _newController,
                  hintText: 'edit_profile.new_password_hint'.tr(),
                  obscureText: true,
                  passwordToggle: true,
                  isEnabled: !loading,
                  textInputAction: TextInputAction.next,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: _validateNew,
                ),
                const SizedBox(height: 12),
                MainTextFormField(
                  controller: _confirmController,
                  hintText: 'edit_profile.confirm_password_hint'.tr(),
                  obscureText: true,
                  passwordToggle: true,
                  isEnabled: !loading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 20),
                CustomButton.full(
                  onTap: loading ? () {} : _submit,
                  theme: CustomButtonTheme(
                    height: 48,
                    backgroundColor: colors.olive,
                    textColor: colors.canvas,
                    borderRadius: 14,
                  ),
                  child: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colors.canvas),
                          ),
                        )
                      : ResponsiveText(
                          'edit_profile.change_password_cta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.canvas,
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(context).pop(),
                  child: ResponsiveText(
                    'common.cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onAuthState,
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          final loading = state.isLoading;
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: errorColor.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: errorColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                ResponsiveText(
                  'edit_profile.delete_password_title',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.oliveDeep,
                  ),
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'edit_profile.delete_password_subtitle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                MainTextFormField(
                  controller: _controller,
                  hintText: 'edit_profile.delete_password_hint'.tr(),
                  obscureText: true,
                  passwordToggle: true,
                  autofocus: true,
                  isEnabled: !loading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  errorText: _serverError?.tr(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (_) {
                    if (_serverError != null) {
                      setState(() => _serverError = null);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'edit_profile.delete_password_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton.full(
                  onTap: loading ? () {} : _submit,
                  theme: CustomButtonTheme(
                    height: 48,
                    backgroundColor: errorColor,
                    textColor: colors.canvas,
                    borderRadius: 14,
                  ),
                  child: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colors.canvas),
                          ),
                        )
                      : ResponsiveText(
                          'edit_profile.delete_password_cta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.canvas,
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(context).pop(),
                  child: ResponsiveText(
                    'common.cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
