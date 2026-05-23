import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_form_field.dart';
import '../widgets/team_scaffold.dart';

const _kMinNameLength = 3;
const _kMaxNameLength = 32;

/// Create a team. Banner + intent are visual-only (not part of the current
/// API contract); only `name` is sent.
class TeamCreateScreen extends StatefulWidget {
  const TeamCreateScreen({super.key});

  @override
  State<TeamCreateScreen> createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends State<TeamCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _intentCtrl = TextEditingController();
  bool _showInlineError = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _intentCtrl.dispose();
    super.dispose();
  }

  bool get _isValid => _nameCtrl.text.trim().length >= _kMinNameLength;

  void _submit(BuildContext context) {
    if (!_isValid) {
      setState(() => _showInlineError = true);
      return;
    }
    setState(() => _showInlineError = false);
    context.read<TeamsCubit>().createTeam(name: _nameCtrl.text.trim());
  }

  void _onChange(_) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.createStatus != b.createStatus,
      listener: (context, state) {
        if (state.createStatus == CreateStatus.success) {
          context.pushReplacementNamed(AppRoutes.teamCreateSuccessName);
        }
      },
      builder: (context, state) {
        final submitting = state.createStatus == CreateStatus.submitting;
        final serverError = state.createStatus == CreateStatus.error
            ? state.errorMessage
            : null;
        final inlineError = _showInlineError
            ? 'teams.create.name_error'
            : null;

        return TeamScaffold(
          child: Column(
            children: [
              ZaadAppBar(
                title: 'teams.create.title',
                subtitle: 'teams.create.step',
                onBack: submitting
                    ? null
                    : context.canPop()
                    ? () => context.pop()
                    : null,
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: submitting,
                  child: Opacity(
                    opacity: submitting ? 0.4 : 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BannerSlot(filled: _nameCtrl.text.isNotEmpty),
                          Transform.translate(
                            offset: const Offset(14, -32),
                            child: Row(
                              children: [
                                TeamDisc(
                                  seed: _nameCtrl.text.isNotEmpty
                                      ? _nameCtrl.text
                                      : '?',
                                  size: 64,
                                  borderColor: colors.canvas,
                                  borderWidth: 3,
                                ),
                                const SizedBox(width: 12),
                                ResponsiveText(
                                  (_nameCtrl.text.isEmpty
                                          ? 'teams.create.add_avatar'
                                          : 'teams.create.avatar_set')
                                      .tr()
                                      .toUpperCase(),
                                  style: ZaadType.fieldLabel.copyWith(
                                    color: _nameCtrl.text.isEmpty
                                        ? colors.oliveSoft
                                        : colors.accentDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TeamFormField(
                            label: 'teams.create.name_label',
                            hint: 'teams.create.name_hint',
                            controller: _nameCtrl,
                            maxLength: _kMaxNameLength,
                            errorText: serverError ?? inlineError,
                            onChanged: _onChange,
                          ),
                          const SizedBox(height: 14),
                          TeamFormField(
                            label: 'teams.create.intent_label',
                            hint: 'teams.create.intent_hint',
                            helperText: 'teams.create.intent_helper',
                            controller: _intentCtrl,
                            minLines: 2,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: ZaadPrimaryButton(
                    label: submitting
                        ? 'teams.create.submitting'.tr()
                        : 'teams.create.cta'.tr(),
                    onTap: () => _submit(context),
                    enabled: _isValid && !submitting,
                    loading: submitting,
                    trailingIcon: _isValid && !submitting
                        ? Icons.check_rounded
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerSlot extends StatelessWidget {
  const _BannerSlot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (filled) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: ZaadRadii.lgAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6E5025),
              colors.olive,
            ],
          ),
          border: Border.all(
            color: colors.olive.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accent.withValues(alpha: 0.5),
                      colors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.shadowDeep.withValues(alpha: 0.45),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: colors.canvas,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: ZaadRadii.lgAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.dune, AppColors.sand],
        ),
        border: Border.all(
          color: colors.accentDeep,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 16,
              color: colors.textArabic,
            ),
            const SizedBox(width: 8),
            ResponsiveText(
              'teams.create.add_banner'.tr().toUpperCase(),
              style: ZaadType.fieldLabel.copyWith(color: colors.textArabic),
            ),
          ],
        ),
      ),
    );
  }
}
