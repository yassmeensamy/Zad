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

  static const uzbek = AppLanguage(
    code: 'uz',
    nativeName: 'O‘zbekcha',
    englishName: 'Uzbek',
    badge: 'UZ',
    isRtl: false,
    usesArabicScript: false,
  );

  static const german = AppLanguage(
    code: 'de',
    nativeName: 'Deutsch',
    englishName: 'German',
    badge: 'DE',
    isRtl: false,
    usesArabicScript: false,
  );

  static const dutch = AppLanguage(
    code: 'nl',
    nativeName: 'Nederlands',
    englishName: 'Dutch',
    badge: 'NL',
    isRtl: false,
    usesArabicScript: false,
  );

  static const spanish = AppLanguage(
    code: 'es',
    nativeName: 'Español',
    englishName: 'Spanish',
    badge: 'ES',
    isRtl: false,
    usesArabicScript: false,
  );

  static const bengali = AppLanguage(
    code: 'bn',
    nativeName: 'বাংলা',
    englishName: 'Bengali',
    badge: 'BN',
    isRtl: false,
    usesArabicScript: false,
  );

  static const persian = AppLanguage(
    code: 'fa',
    nativeName: 'فارسی',
    englishName: 'Persian',
    badge: 'فا',
    isRtl: true,
    usesArabicScript: true,
  );

  static const hindi = AppLanguage(
    code: 'hi',
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
    badge: 'HI',
    isRtl: false,
    usesArabicScript: false,
  );

  static const kazakh = AppLanguage(
    code: 'kk',
    nativeName: 'Қазақша',
    englishName: 'Kazakh',
    badge: 'KK',
    isRtl: false,
    usesArabicScript: false,
  );

  static const chinese = AppLanguage(
    code: 'zh',
    nativeName: '简体中文',
    englishName: 'Chinese',
    badge: 'ZH',
    isRtl: false,
    usesArabicScript: false,
  );

  static const albanian = AppLanguage(
    code: 'sq',
    nativeName: 'Shqip',
    englishName: 'Albanian',
    badge: 'SQ',
    isRtl: false,
    usesArabicScript: false,
  );

  static const bosnian = AppLanguage(
    code: 'bs',
    nativeName: 'Bosanski',
    englishName: 'Bosnian',
    badge: 'BS',
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
    uzbek,
    german,
    dutch,
    spanish,
    bengali,
    persian,
    hindi,
    kazakh,
    chinese,
    albanian,
    bosnian,
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
