import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/widgets/create_team_sheet.dart';
import '../../../teams/presentation/widgets/team_empty_illustration.dart';

class LeaderboardNoTeam extends StatelessWidget {
  const LeaderboardNoTeam({super.key, this.onChanged});

  final VoidCallback? onChanged;

  Future<void> _onCreate(BuildContext context) async {
    final created = await showCreateTeamSheet(context);
    if (created && context.mounted) {
      context.goNamed(AppRoutes.teamCreateSuccessName);
    }
  }

  Future<void> _onJoin(BuildContext context) async {
    await context.pushNamed(AppRoutes.teamJoinName);
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamsCubit>(
      create: (_) => sl<TeamsCubit>(),
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TeamEmptyIllustration(size: 190),
            const SizedBox(height: 24),
            ResponsiveText(
              'leaderboard.no_team.title',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 19,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              'leaderboard.no_team.lede',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: colors.oliveSoft,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton.full(
              onTap: () => _onCreate(context),
              theme: CustomButtonTheme(
                height: 50,
                useGradient: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.oliveSoft, colors.olive, colors.oliveDeep],
                ),
                borderRadius: ZaadRadii.lg,
                textColor: colors.canvas,
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.canvas,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText(
                    'leaderboard.no_team.create'.tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.canvas,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.add_rounded, size: 18, color: colors.canvas),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomButton.full(
              onTap: () => _onJoin(context),
              theme: CustomButtonTheme(
                height: 46,
                backgroundColor: colors.canvas.withValues(alpha: 0.45),
                borderColor: colors.olive,
                borderRadius: ZaadRadii.lg,
                textColor: colors.oliveDeep,
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: colors.oliveDeep,
                ),
              ),
              child: ResponsiveText(
                'leaderboard.no_team.join'.tr().toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: colors.oliveDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
