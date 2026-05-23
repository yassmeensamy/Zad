import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import 'team_form_field.dart';

const _kMinNameLength = 3;
const _kMaxNameLength = 32;

/// Centered popup that collects only the team name and submits.
/// Returns `true` when the team was created successfully so the caller
/// can route into the team flow.
Future<bool> showCreateTeamSheet(BuildContext context) async {
  final cubit = context.read<TeamsCubit>();
  cubit.resetCreateState();

  final result = await CustomDialog.show<bool>(
    context: context,
    barrierDismissible: false,
    radius: 24,
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
    child: BlocProvider<TeamsCubit>.value(
      value: cubit,
      child: const _CreateTeamDialog(),
    ),
  );
  return result ?? false;
}

class _CreateTeamDialog extends StatefulWidget {
  const _CreateTeamDialog();

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _ctrl = TextEditingController();
  final _showInlineError = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _ctrl.dispose();
    _showInlineError.dispose();
    super.dispose();
  }

  bool _isValid(String text) => text.trim().length >= _kMinNameLength;

  void _submit() {
    if (!_isValid(_ctrl.text)) {
      _showInlineError.value = true;
      return;
    }
    _showInlineError.value = false;
    context.read<TeamsCubit>().createTeam(name: _ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.createStatus != b.createStatus,
      listener: (context, state) {
        if (state.createStatus == CreateStatus.success) {
          context.pop(true);
        }
      },
      builder: (context, state) {
        final submitting = state.createStatus == CreateStatus.submitting;
        final serverError = state.createStatus == CreateStatus.error
            ? state.errorMessage
            : null;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AbsorbPointer(
              absorbing: submitting,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DialogHeader(),
                  const SizedBox(height: 12),
                  ResponsiveText(
                    'teams.create.sheet_lede',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.5,
                      height: 1.55,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showInlineError,
                    builder: (_, showInlineError, _) {
                      final inlineError = showInlineError
                          ? 'teams.create.name_error'
                          : null;
                      return TeamFormField(
                        label: 'teams.create.name_label',
                        hint: 'teams.create.name_hint',
                        controller: _ctrl,
                        maxLength: _kMaxNameLength,
                        errorText: serverError ?? inlineError,
                        enabled: !submitting,
                        fillColor: AppColors.creamLight,
                        labelStyle: AppTextStyles.labelLarge.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _ctrl,
                    builder: (_, value, _) {
                      final isValid = _isValid(value.text);
                      return ZaadPrimaryButton(
                        label: submitting
                            ? 'teams.create.submitting'.tr()
                            : 'teams.create.cta'.tr(),
                        onTap: _submit,
                        enabled: isValid && !submitting,
                        loading: submitting,
                        height: 46,
                        borderRadius: ZaadRadii.md,
                        fontSize: 12,
                        letterSpacing: 2.16,
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: ZaadCircleIconButton.close(
                enabled: !submitting,
                onTap: () => context.pop(false),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ResponsiveText(
            'teams.create.sheet_eyebrow',
            textAlign: TextAlign.center,
            style: ZaadType.eyebrowSm.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: ZaadType.titleAccent.copyWith(color: colors.oliveDeep),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${'teams.create.sheet_title_lead'.tr()} '),
                  TextSpan(
                    text: 'teams.create.sheet_title_accent'.tr(),
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
          Container(width: 28, height: 1, color: colors.accent),
        ],
      ),
    );
  }
}
