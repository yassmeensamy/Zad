import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_model.dart';
import '../../../core/navigation/app_routes.dart';
import '../../language/presentation/modals/language_dialog.dart';
import '../../theme/presentation/cubit/theme_cubit.dart';
import '../presentation/widgets/change_password_dialog.dart';
import 'profile_section.dart';

String _themeModeLabelKey(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'profile.theme_system',
  ThemeMode.light => 'profile.theme_light',
  ThemeMode.dark => 'profile.theme_dark',
};

List<ProfileSection> profileSections(
  BuildContext context, {
  bool isGuest = false,
}) => isGuest ? _guestSections(context) : _userSections(context);

ProfileMenuItem _languageItem(BuildContext context) => ProfileMenuItem(
  icon: Icons.translate_rounded,
  titleKey: 'profile.language',
  trailingText: context.locale.languageCode == 'ar' ? 'العربية' : 'English',
  onTap: () => LanguageDialog.show(context),
);

ProfileMenuItem _themeItem(BuildContext context) => ProfileMenuItem(
  icon: Icons.color_lens_outlined,
  titleKey: 'profile.theme',
  trailingText: _themeModeLabelKey(context.watch<ThemeCubit>().state).tr(),
  onTap: () {
    final cubit = context.read<ThemeCubit>();
    final isDark =
        cubit.state == ThemeMode.dark ||
        (cubit.state == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    cubit.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  },
);

List<ProfileSection> _guestSections(BuildContext context) => [
  ProfileSection(
    titleKey: 'profile.account',
    items: [
      ProfileMenuItem(
        icon: Icons.workspace_premium_outlined,
        titleKey: 'profile.upgrade_account',
        onTap: () => context.goNamed(AppRoutes.signupName),
      ),
      ProfileMenuItem(
        icon: Icons.person_outline_rounded,
        titleKey: 'profile.view_profile',
        onTap: () => context.pushNamed(AppRoutes.editProfileName),
      ),
      ProfileMenuItem(
        icon: Icons.help_outline_rounded,
        titleKey: 'profile.help_support',
        onTap: () => context.pushNamed(AppRoutes.helpCenterName),
      ),
    ],
  ),
  ProfileSection(
    titleKey: 'profile.practice',
    items: [_languageItem(context), _themeItem(context)],
  ),
];

List<ProfileSection> _userSections(BuildContext context) => [
  ProfileSection(
    titleKey: 'profile.practice',
    items: [
      ProfileMenuItem(
        icon: Icons.notifications_none_rounded,
        titleKey: 'profile.reminders',
        onTap: () => context.pushNamed(AppRoutes.notificationsName),
      ),
      _languageItem(context),
      _themeItem(context),
    ],
  ),
  ProfileSection(
    titleKey: 'profile.library',
    items: [
      ProfileMenuItem(
        icon: Icons.drafts_outlined,
        titleKey: 'profile.drafts',
        onTap: () => context.pushNamed(AppRoutes.draftsName),
        visibleFor: const [UserRole.child, UserRole.parent],
      ),
      ProfileMenuItem(
        icon: Icons.download_done_rounded,
        titleKey: 'profile.downloads',
        onTap: () => context.pushNamed(AppRoutes.downloadsName),
        visibleFor: const [UserRole.child, UserRole.parent],
      ),
      ProfileMenuItem(
        icon: Icons.family_restroom_rounded,
        titleKey: 'profile.my_children',
        onTap: () => context.pushNamed(AppRoutes.myChildrenName),
        visibleFor: const [UserRole.parent],
      ),
    ],
  ),
  ProfileSection(
    titleKey: 'profile.account',
    items: [
      ProfileMenuItem(
        icon: Icons.person_outline_rounded,
        titleKey: 'profile.edit_profile',
        onTap: () => context.pushNamed(AppRoutes.editProfileName),
      ),
      ProfileMenuItem(
        icon: Icons.lock_reset_rounded,
        titleKey: 'edit_profile.change_password',
        onTap: () => ChangePasswordDialog.show(context),
      ),
   
      ProfileMenuItem(
        icon: Icons.help_outline_rounded,
        titleKey: 'profile.help_support',
        onTap: () => context.pushNamed(AppRoutes.helpCenterName),
      ),
      ProfileMenuItem(
        icon: Icons.support_agent_outlined,
        titleKey: 'profile.support_tickets',
        onTap: () => context.pushNamed(AppRoutes.supportTicketsName),
      ),
    ],
  ),
];
