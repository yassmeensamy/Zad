import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../widgets/create_team_sheet.dart';
import '../widgets/team_empty_illustration.dart';
import '../widgets/team_scaffold.dart';

/// Empty state — two doors, equal weight: Create or Join.
class TeamEmptyScreen extends StatelessWidget {
  const TeamEmptyScreen({super.key});

  Future<void> _onCreate(BuildContext context) async {
    final created = await showCreateTeamSheet(context);
    if (created && context.mounted) {
      // Route to the celebration screen — invite code chip + 'Enter team
      // home' CTA. From there the user lands on /teams/home.
      context.goNamed(AppRoutes.teamCreateSuccessName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TeamScaffold(
      appBar: ZaadAppBar(
        title: 'teams.empty.title',
        subtitle: 'teams.empty.eyebrow',
        backgroundColor: Colors.transparent,
        onBack: () => context.canPop()
            ? context.pop()
            : context.goNamed(AppRoutes.homeName),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          children: [
            const Spacer(),
            const TeamEmptyIllustration(),
            const SizedBox(height: 28),
            ResponsiveText(
              'teams.empty.title_lede',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 22,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              'teams.empty.hadith_ar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: colors.textArabic,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ResponsiveText(
                'teams.empty.lede',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  color: colors.oliveSoft,
                  height: 1.55,
                ),
              ),
            ),
            const Spacer(flex: 2),
            CustomButton.full(
              onTap: () => _onCreate(context),
              theme: CustomButtonTheme(
                height: 52,
                useGradient: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.ctaTop, colors.ctaMid, colors.ctaBottom],
                ),
                borderRadius: ZaadRadii.lg,
                textColor: colors.onCta,
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onCta,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText(
                    'teams.empty.cta_create'.tr(),
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
              onTap: () => context.pushNamed(AppRoutes.teamJoinName),
              theme: CustomButtonTheme(
                height: 48,
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
                'teams.empty.cta_join'.tr().toUpperCase(),
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
