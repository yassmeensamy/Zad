import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';

class ProfileSection {
  final String titleKey;
  final List<ProfileMenuItem> items;

  const ProfileSection({required this.titleKey, required this.items});
}

class ProfileMenuItem {
  final IconData icon;
  final String titleKey;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Roles allowed to see this item. `null` means visible to everyone.
  final List<UserRole>? visibleFor;

  const ProfileMenuItem({
    required this.icon,
    required this.titleKey,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.visibleFor,
  });

  bool isVisibleFor(UserRole? role) =>
      visibleFor == null || (role != null && visibleFor!.contains(role));
}
