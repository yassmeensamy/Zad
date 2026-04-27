import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../language/presentation/modals/language_dialog.dart';
import 'profile_section.dart';

List<ProfileSection> profileSections(
  BuildContext context, {
  required bool remindersEnabled,
  required ValueChanged<bool> onRemindersChanged,
}) => [
  ProfileSection(
    titleKey: 'profile.practice',
    items: [
      ProfileMenuItem(
        icon: Icons.notifications_none_rounded,
        titleKey: 'profile.reminders',
        trailing: _RemindersSwitch(
          value: remindersEnabled,
          onChanged: onRemindersChanged,
        ),
        onTap: () => onRemindersChanged(!remindersEnabled),
      ),
      ProfileMenuItem(
        icon: Icons.translate_rounded,
        titleKey: 'profile.language',
        trailingText:
            context.locale.languageCode == 'ar' ? 'العربية' : 'English',
        onTap: () => LanguageDialog.show(context),
      ),
      ProfileMenuItem(
        icon: Icons.color_lens_outlined,
        titleKey: 'profile.theme',
        trailingText: 'profile.theme_system'.tr(),
      ),
    ],
  ),
  const ProfileSection(
    titleKey: 'profile.library',
    items: [
      ProfileMenuItem(
        icon: Icons.drafts_outlined,
        titleKey: 'profile.drafts',
      ),
      ProfileMenuItem(
        icon: Icons.family_restroom_rounded,
        titleKey: 'profile.my_children',
      ),
    ],
  ),
  const ProfileSection(
    titleKey: 'profile.account',
    items: [
      ProfileMenuItem(
        icon: Icons.person_outline_rounded,
        titleKey: 'profile.edit_profile',
      ),
      ProfileMenuItem(
        icon: Icons.privacy_tip_outlined,
        titleKey: 'profile.privacy',
      ),
      ProfileMenuItem(
        icon: Icons.help_outline_rounded,
        titleKey: 'profile.help_support',
      ),
    ],
  ),
];

class _RemindersSwitch extends StatelessWidget {
  const _RemindersSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.canvas,
      activeTrackColor: colors.accent,
      inactiveThumbColor: colors.canvas,
      inactiveTrackColor: colors.textArabic.withValues(alpha: 0.18),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.accent
            : colors.textArabic.withValues(alpha: 0.18),
      ),
    );
  }
}
