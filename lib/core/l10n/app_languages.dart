import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// One language the app ships translations for.
///
/// Everything the UI needs to describe a language — its native name, the badge
/// shown in the picker, and its writing direction — lives here rather than in
/// `languageCode == 'ar' ? … : …` ternaries scattered across the widgets. Adding
/// a fourth language should mean adding an entry to [AppLanguages.all] and an
/// `assets/translations/<code>.json`, nothing more.
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

  /// ISO 639-1 code. Doubles as the translation filename, the `Accept-Language`
  /// header value, and the `language` field sent to the backend.
  final String code;

  /// The language's name written in itself — what the picker and the profile
  /// row show, so a reader who can't read the current UI language can still
  /// find their own.
  final String nativeName;

  /// The same name in English, shown as the picker's secondary line.
  final String englishName;

  /// One or two characters for the picker's square badge.
  final String badge;

  /// Right-to-left script. Both Arabic and Urdu are.
  final bool isRtl;

  /// Whether [nativeName] is written in the Arabic script. Those glyphs sit
  /// lower and smaller than Latin at the same point size, so the picker bumps
  /// them up a step.
  final bool usesArabicScript;

  Locale get locale => Locale(code);
}

/// The languages this app supports, and the lookups over them.
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

  /// Order here is the order the language picker lists them in.
  static const List<AppLanguage> all = [english, arabic, urdu, indonesian];

  /// Used when the device locale isn't one we ship, and when a cached or
  /// server-sent code doesn't resolve.
  static const AppLanguage fallback = english;

  /// For `EasyLocalization.supportedLocales`.
  static List<Locale> get locales => [for (final l in all) l.locale];

  /// For `initializeDateFormatting` / `timeago.setLocaleMessages`.
  static List<String> get codes => [for (final l in all) l.code];

  /// Resolves a language code to its [AppLanguage], falling back to [fallback]
  /// for null or unknown codes rather than throwing.
  static AppLanguage byCode(String? code) => all.firstWhere(
    (l) => l.code == code,
    orElse: () => fallback,
  );

  static bool isSupported(String? code) => all.any((l) => l.code == code);
}

extension AppLanguageContext on BuildContext {
  /// The [AppLanguage] currently driving the UI.
  AppLanguage get appLanguage => AppLanguages.byCode(locale.languageCode);
}
