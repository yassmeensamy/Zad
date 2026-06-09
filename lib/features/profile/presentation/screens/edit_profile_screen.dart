import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../cubit/edit_profile_form_cubit.dart';
import '../cubit/edit_profile_form_state.dart';
import '../widgets/delete_account_dialog.dart';
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
      avatar: updated.avatar,
    );
  }

  Future<void> _confirmDelete() => DeleteAccountDialog.show(context);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
    return BlocSelector<UserCubit, UserState, UserModel?>(
      selector: (state) => state.user,
      builder: (context, user) {
        return BlocSelector<EditProfileFormCubit, EditProfileFormState, bool>(
          selector: (state) => state.isDirtyAgainst(user),
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

