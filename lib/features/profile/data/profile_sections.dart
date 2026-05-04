import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_model.dart';
import '../../../core/navigation/app_routes.dart';
import '../../language/presentation/modals/language_dialog.dart';
import '../presentation/widgets/change_password_dialog.dart';
import 'profile_section.dart';

List<ProfileSection> profileSections(BuildContext context) => [
  ProfileSection(
    titleKey: 'profile.practice',
    items: [
      ProfileMenuItem(
        icon: Icons.notifications_none_rounded,
        titleKey: 'profile.reminders',
        onTap: () => context.pushNamed(AppRoutes.notificationsName),
      ),
      ProfileMenuItem(
        icon: Icons.translate_rounded,
        titleKey: 'profile.language',
        trailingText: context.locale.languageCode == 'ar'
            ? 'العربية'
            : 'English',
        onTap: () => LanguageDialog.show(context),
      ),
      ProfileMenuItem(
        icon: Icons.color_lens_outlined,
        titleKey: 'profile.theme',
        trailingText: 'profile.theme_system'.tr(),
      ),
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
      const ProfileMenuItem(
        icon: Icons.privacy_tip_outlined,
        titleKey: 'profile.privacy',
      ),
      ProfileMenuItem(
        icon: Icons.help_outline_rounded,
        titleKey: 'profile.help_support',
        onTap: () => context.pushNamed(AppRoutes.helpCenterName),
      ),
    ],
  ),
];
