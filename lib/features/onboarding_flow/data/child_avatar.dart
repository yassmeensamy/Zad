import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// One of 8 illustrated avatars used for child profiles.
/// All choices are drawn from Islamic visual culture so the picker feels
/// familiar to Muslim families (mosque, crescent, lantern, Qur'an, etc.).
enum ChildAvatar {
  mosque,
  crescent,
  star,
  lantern,
  quran,
  prayerBeads,
  palm,
  dates;

  String get label => switch (this) {
    ChildAvatar.mosque => 'Mosque',
    ChildAvatar.crescent => 'Crescent',
    ChildAvatar.star => 'Star',
    ChildAvatar.lantern => 'Lantern',
    ChildAvatar.quran => 'Qur\'an',
    ChildAvatar.prayerBeads => 'Tasbih',
    ChildAvatar.palm => 'Date palm',
    ChildAvatar.dates => 'Dates',
  };

  IconData get icon => switch (this) {
    ChildAvatar.mosque => Icons.mosque_rounded,
    ChildAvatar.crescent => Icons.nightlight_round,
    ChildAvatar.star => Icons.auto_awesome_rounded,
    ChildAvatar.lantern => Icons.light_mode_rounded,
    ChildAvatar.quran => Icons.menu_book_rounded,
    ChildAvatar.prayerBeads => Icons.bubble_chart_rounded,
    ChildAvatar.palm => Icons.park_rounded,
    ChildAvatar.dates => Icons.eco_rounded,
  };

  /// Background gradient for the avatar tile, chosen to feel kid-friendly
  /// while staying inside the desert/olive palette.
  List<Color> get gradient => switch (this) {
    ChildAvatar.mosque => const [AppColors.oliveDeep, AppColors.olive],
    ChildAvatar.crescent => const [Color(0xFFEDDFB6), AppColors.oliveSoft],
    ChildAvatar.star => const [Color(0xFFF1E2BE), AppColors.amber],
    ChildAvatar.lantern => const [Color(0xFFF6E6C4), AppColors.amberDeep],
    ChildAvatar.quran => const [Color(0xFFE5DAB6), AppColors.oliveLeaf],
    ChildAvatar.prayerBeads => const [Color(0xFFF1E2BE), Color(0xFFE8C088)],
    ChildAvatar.palm => const [Color(0xFFEDDFB6), AppColors.olive],
    ChildAvatar.dates => const [Color(0xFFF6E6C4), Color(0xFFE8C088)],
  };

  Color get foreground => switch (this) {
    ChildAvatar.mosque => AppColors.ivory,
    ChildAvatar.quran => AppColors.ivory,
    ChildAvatar.palm => AppColors.ivory,
    _ => AppColors.dateDeep,
  };
}

class ChildDraft {
  const ChildDraft({
    required this.id,
    this.name = '',
    this.age = '',
    this.password = '',
    this.avatar = ChildAvatar.mosque,
  });

  final String id;
  final String name;
  final String age;
  final String password;
  final ChildAvatar avatar;

  bool get hasPassword => password.isNotEmpty;

  /// Best-effort birthDate inferred from the [age] field. Returns null
  /// when the age string isn't a positive integer.
  DateTime? get inferredBirthDate {
    final years = int.tryParse(age.trim());
    if (years == null || years <= 0) return null;
    final now = DateTime.now();
    return DateTime(now.year - years, now.month, now.day);
  }

  ChildDraft copyWith({
    String? name,
    String? age,
    String? password,
    ChildAvatar? avatar,
  }) => ChildDraft(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    password: password ?? this.password,
    avatar: avatar ?? this.avatar,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildDraft &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.password == password &&
        other.avatar == avatar;
  }

  @override
  int get hashCode => Object.hash(id, name, age, password, avatar);
}
