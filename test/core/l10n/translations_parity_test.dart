import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/l10n/app_languages.dart';

/// Guards the translation bundles against the two ways they silently rot:
/// a key added to one language and forgotten in the others (which renders the
/// raw key path on screen), and a placeholder dropped or renamed during
/// translation (which renders a literal `{name}` to the user).
void main() {
  Map<String, String> flatten(Map<String, dynamic> node, [String prefix = '']) {
    final flat = <String, String>{};
    node.forEach((key, value) {
      final path = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        flat.addAll(flatten(value, path));
      } else {
        flat[path] = value.toString();
      }
    });
    return flat;
  }

  File fileFor(String code) => File('assets/translations/$code.json');

  Map<String, String> load(String code) => flatten(
    json.decode(fileFor(code).readAsStringSync()) as Map<String, dynamic>,
  );

  /// Placeholders come in two shapes: `{}` positional and `{named}`.
  final placeholder = RegExp(r'\{[a-zA-Z0-9_]*\}');

  List<String> placeholdersIn(String value) =>
      placeholder.allMatches(value).map((m) => m[0]!).toList()..sort();

  /// Leaves of an `easy_localization` plural block. A language may legitimately
  /// spell the count into the word instead of interpolating it — English's
  /// "No replies" / "1 reply" do it, and so does Arabic's dual ("ردّان") — so
  /// these are exempt from placeholder parity.
  const pluralCategories = {'zero', 'one', 'two', 'few', 'many', 'other'};
  bool isPluralLeaf(String key) =>
      pluralCategories.contains(key.split('.').last);

  final reference = load(AppLanguages.fallback.code);

  test('every supported language ships a translation file', () {
    for (final language in AppLanguages.all) {
      expect(
        fileFor(language.code).existsSync(),
        isTrue,
        reason: '${language.englishName} has no assets/translations file',
      );
    }
  });

  for (final language in AppLanguages.all) {
    if (language.code == AppLanguages.fallback.code) continue;

    group(language.englishName, () {
      final translations = load(language.code);

      test('has exactly the same keys as the fallback language', () {
        expect(
          translations.keys.toSet().difference(reference.keys.toSet()),
          isEmpty,
          reason: 'keys present in ${language.code}.json but not the fallback',
        );
        expect(
          reference.keys.toSet().difference(translations.keys.toSet()),
          isEmpty,
          reason: 'keys missing from ${language.code}.json',
        );
      });

      test('has no blank values', () {
        expect(
          translations.entries
              .where((e) => e.value.trim().isEmpty)
              .map((e) => e.key),
          isEmpty,
        );
      });

      test('preserves every placeholder', () {
        final mismatched = <String>[];
        for (final entry in reference.entries) {
          if (isPluralLeaf(entry.key)) continue;
          final translated = translations[entry.key];
          if (translated == null) continue;
          final expected = placeholdersIn(entry.value).join(',');
          final actual = placeholdersIn(translated).join(',');
          if (expected != actual) {
            mismatched.add('${entry.key}: expected [$expected], got [$actual]');
          }
        }
        expect(mismatched, isEmpty);
      });
    });
  }
}
