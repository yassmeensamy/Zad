import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../teams/presentation/widgets/team_card.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/cubit/teams_state.dart';

class HomeTeamSection extends StatelessWidget {
  const HomeTeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.hasTeam) {
          final cubit = context.read<TeamsCubit>();
          if (state.members == null) cubit.loadTeamMembers();
          if (state.summary == null) cubit.loadTeamProgress();
        }
      },
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.team != b.team ||
          a.members != b.members ||
          a.summary != b.summary,
      builder: (context, state) {
        void openTeam() => context.pushNamed(AppRoutes.teamsName);
        final team = state.team;
        if (!state.hasTeam || team == null) {
          // One shared card for both themes; colors come from the semantic
          // tokens so light reads as warm cream and dark as roasted brown.
          return _JoinTeamCard(onTap: openTeam);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeamSectionHeader(onOpen: openTeam),
            const SizedBox(height: 11),
            GestureDetector(
              onTap: openTeam,
              behavior: HitTestBehavior.opaque,
              child: TeamCard(
                team: team,
                members: state.members?.members,
                summary: state.summary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _JoinTeamCard extends StatelessWidget {
  const _JoinTeamCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TeamCardShell(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        // Centre the halo above the crest rather than the corner.
        haloCenter: const Alignment(0, -1.15),
        haloRadius: 1.15,
        child: Column(
          children: [
            _JoinCrest(colors: colors),
            const SizedBox(height: 13),
            ResponsiveText(
              'home.team.join_title',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                fontSize: 21,
                height: 1.05,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ResponsiveText(
                'home.team.join_subtitle',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.5,
                  height: 1.5,
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ZaadPrimaryButton(
                    label: 'home.team.create'.tr().toUpperCase(),
                    onTap: onTap,
                    trailingIcon: Icons.add_rounded,
                    height: 44,
                    borderRadius: 13,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 10.5 * 0.16,
                    iconSize: 12,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _JoinGhostButton(
                    label: 'home.team.join_with_code'.tr(),
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Halo + gilded glass disc holding the companions glyph. Tokens keep it warm
/// gold on cream in light and a glowing amber medallion on brown in dark.
class _JoinCrest extends StatelessWidget {
  const _JoinCrest({required this.colors});

  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.accentSoft.withValues(alpha: 0.55),
                  colors.accentSoft.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.72],
              ),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.goldLight.withValues(alpha: 0.50),
                  colors.accent.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.60),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.22),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(
              Icons.groups_outlined,
              size: 28,
              color: colors.accentDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinGhostButton extends StatelessWidget {
  const _JoinGhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: colors.accent.withValues(alpha: 0.05),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.20),
            width: 1.5,
          ),
        ),
        child: ResponsiveText(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
            letterSpacing: 10.5 * 0.16,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TeamSectionHeader extends StatelessWidget {
  const _TeamSectionHeader({required this.onOpen});

  final VoidCallback onOpen;

  static const double _dividerWidth = 16;
  static const double _dividerHeight = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: _dividerWidth,
          height: _dividerHeight,
          color: colors.accent,
        ),
        const SizedBox(width: 8),
        ResponsiveText(
          'home.team.joined_eyebrow',
          // tracking 0.306 == the prior 3.06 over the default size 10.
          style: AppTextStyles.eyebrow(tracking: 0.306, color: colors.accent),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onOpen,
          behavior: HitTestBehavior.opaque,
          child: ResponsiveText(
            'home.team.open'.tr().toUpperCase(),
            // tracking 0.152 == the prior 1.52 over the default size 10.
            style: AppTextStyles.eyebrow(
              tracking: 0.152,
              weight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
