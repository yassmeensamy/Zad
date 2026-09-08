import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.badge,
    required this.isRtl,
    required this.usesArabicScript,
  });

  final String code;

  final String nativeName;

  final String englishName;

  final String badge;

  final bool isRtl;

  final bool usesArabicScript;

  Locale get locale => Locale(code);
}

abstract final class AppLanguages {
  static const english = AppLanguage(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    badge: 'EN',
    isRtl: false,
    usesArabicScript: false,
  );

  static const arabic = AppLanguage(
    code: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    badge: 'ع',
    isRtl: true,
    usesArabicScript: true,
  );

  static const urdu = AppLanguage(
    code: 'ur',
    nativeName: 'اردو',
    englishName: 'Urdu',
    badge: 'اُ',
    isRtl: true,
    usesArabicScript: true,
  );

  static const indonesian = AppLanguage(
    code: 'id',
    nativeName: 'Bahasa Indonesia',
    englishName: 'Indonesian',
    badge: 'ID',
    isRtl: false,
    usesArabicScript: false,
  );

  static const russian = AppLanguage(
    code: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    badge: 'RU',
    isRtl: false,
    usesArabicScript: false,
  );

  static const turkish = AppLanguage(
    code: 'tr',
    nativeName: 'Türkçe',
    englishName: 'Turkish',
    badge: 'TR',
    isRtl: false,
    usesArabicScript: false,
  );

  static const french = AppLanguage(
    code: 'fr',
    nativeName: 'Français',
    englishName: 'French',
    badge: 'FR',
    isRtl: false,
    usesArabicScript: false,
  );

  static const List<AppLanguage> all = [
    english,
    arabic,
    urdu,
    indonesian,
    russian,
    turkish,
    french,
  ];

  static const AppLanguage fallback = english;

  static List<Locale> get locales => [for (final l in all) l.locale];

  static List<String> get codes => [for (final l in all) l.code];

  static AppLanguage byCode(String? code) => all.firstWhere(
    (l) => l.code == code,
    orElse: () => fallback,
  );

  static bool isSupported(String? code) => all.any((l) => l.code == code);
}

extension AppLanguageContext on BuildContext {
  AppLanguage get appLanguage => AppLanguages.byCode(locale.languageCode);
}
