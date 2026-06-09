import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/widgets/zaad_text_field.dart';

class DeleteAccountDialog {
  const DeleteAccountDialog._();

  static Future<void> show(BuildContext context) {
    return CustomDialog.show<void>(
      context: context,
      barrierDismissible: false,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: const _DeleteAccountDialog(),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;
  late final ValueNotifier<String?> _serverError;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    _serverError = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _controller.dispose();
    _serverError.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _serverError.value = null;
    context.read<AuthCubit>().deleteAccount(_controller.text);
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state.isNotLoggedIn) {
      Navigator.of(context).pop();
      context.goNamed(AppRoutes.loginName);
    } else if (state.isError) {
      _serverError.value = state.errorMessage;
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
    final colors = context.appColors;
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
                    const SizedBox(height: 18),
                    ValueListenableBuilder<String?>(
                      valueListenable: _serverError,
                      builder: (context, serverError, _) {
                        return ZaadTextField(
                          hintText: 'edit_profile.delete_password_hint',
                          controller: _controller,
                          enabled: !loading,
                          obscureText: true,
                          passwordToggle: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          errorText: serverError?.tr(),
                          onChanged: (_) {
                            if (_serverError.value != null) {
                              _serverError.value = null;
                            }
                          },
                          onFieldSubmitted: (_) => _submit(),
                          validator: _validateRequired,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colors.oliveSoft,
                            size: 20,
                          ),
                        );
                      },
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
    final eyebrowColor =
        danger ? errorColor.withValues(alpha: 0.85) : colors.oliveSoft;
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
          Container(width: 28, height: 1, color: ruleColor),
        ],
      ),
    );
  }
}
