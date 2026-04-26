import 'package:flutter/material.dart';

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

  const ProfileMenuItem({
    required this.icon,
    required this.titleKey,
    this.trailingText,
    this.trailing,
    this.onTap,
  });
}
