import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';

class TeamJoinSuccessScreen extends StatelessWidget {
  const TeamJoinSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<TeamsCubit, TeamsState>(
      buildWhen: (a, b) => a.team != b.team,
      builder: (context, state) {
        final team = state.team;
        if (team == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.goNamed(AppRoutes.teamHomeName),
          );
          return const TeamScaffold(child: SizedBox.shrink());
        }

        return TeamScaffold(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                _GateHalo(seed: team.name),
                const SizedBox(height: 20),
                ResponsiveText(
                  'teams.join.success_arabic',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 28,
                    color: colors.oliveDeep,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.displaySmall.copyWith(
                      fontSize: 22,
                      color: colors.oliveDeep,
                    ),
                    children: [
                      TextSpan(text: '${'teams.join.success_youre_in'.tr()} '),
                      TextSpan(
                        text: '${team.name}.',
                        style: TextStyle(color: colors.textArabic),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ResponsiveText(
                    'teams.join.success_lede'.tr(
                      namedArgs: {'count': '${team.memberCount}'},
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: colors.oliveSoft,
                      height: 1.55,
                    ),
                  ),
                ),
                const Spacer(),
                ZaadPrimaryButton(
                  label: 'teams.join.success_cta'.tr(),
                  onTap: () => context.goNamed(AppRoutes.teamHomeName),
                  trailingIcon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GateHalo extends StatelessWidget {
  const _GateHalo({required this.seed});
  final String seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.accentDeep.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.accentDeep.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
          ),
          TeamDisc(seed: seed, size: 88, fontSize: 30),
          Positioned(
            right: 14,
            bottom: 14,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.success,
                border: Border.all(color: colors.canvas, width: 3),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: colors.canvas,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
