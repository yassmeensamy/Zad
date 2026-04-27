import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// One of 8 illustrated avatars used for child profiles.
enum ChildAvatar {
  camel,
  lion,
  owl,
  star,
  moon,
  lantern,
  gazelle,
  palm;

  String get label => switch (this) {
        ChildAvatar.camel => 'Camel',
        ChildAvatar.lion => 'Lion',
        ChildAvatar.owl => 'Owl',
        ChildAvatar.star => 'Star',
        ChildAvatar.moon => 'Moon',
        ChildAvatar.lantern => 'Lantern',
        ChildAvatar.gazelle => 'Gazelle',
        ChildAvatar.palm => 'Date palm',
      };

  IconData get icon => switch (this) {
        ChildAvatar.camel => Icons.pets_rounded,
        ChildAvatar.lion => Icons.emoji_nature_rounded,
        ChildAvatar.owl => Icons.flutter_dash_rounded,
        ChildAvatar.star => Icons.auto_awesome_rounded,
        ChildAvatar.moon => Icons.nightlight_round,
        ChildAvatar.lantern => Icons.light_mode_rounded,
        ChildAvatar.gazelle => Icons.cruelty_free_rounded,
        ChildAvatar.palm => Icons.park_rounded,
      };

  /// Background gradient for the avatar tile, chosen to feel kid-friendly
  /// while staying inside the desert/olive palette.
  List<Color> get gradient => switch (this) {
        ChildAvatar.camel => const [Color(0xFFF1E2BE), Color(0xFFE8C088)],
        ChildAvatar.lion => const [Color(0xFFF6E6C4), Color(0xFFE8C088)],
        ChildAvatar.owl => const [Color(0xFFE5DAB6), AppColors.oliveLeaf],
        ChildAvatar.star => const [Color(0xFFEDDFB6), AppColors.oliveSoft],
        ChildAvatar.moon => const [AppColors.oliveDeep, AppColors.olive],
        ChildAvatar.lantern => const [Color(0xFFF1E2BE), AppColors.amber],
        ChildAvatar.gazelle => const [Color(0xFFF6E6C4), AppColors.amberDeep],
        ChildAvatar.palm => const [Color(0xFFEDDFB6), AppColors.olive],
      };

  Color get foreground => switch (this) {
        ChildAvatar.moon => AppColors.ivory,
        ChildAvatar.owl => AppColors.ivory,
        ChildAvatar.star => AppColors.ivory,
        ChildAvatar.palm => AppColors.ivory,
        _ => AppColors.dateDeep,
      };
}

class ChildDraft {
  ChildDraft({this.name = '', this.age = '', this.avatar = ChildAvatar.lion});

  String name;
  String age;
  ChildAvatar avatar;
}
