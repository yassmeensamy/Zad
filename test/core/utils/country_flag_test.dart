import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/country_flag.dart';
import 'package:my_app/features/onboarding_flow/data/country_model.dart';

void main() {
  group('countryFlagEmoji', () {
    test('maps an ISO alpha-2 code to regional indicator symbols', () {
      expect(countryFlagEmoji('EG'), '\u{1F1EA}\u{1F1EC}');
      expect(countryFlagEmoji('SA'), '\u{1F1F8}\u{1F1E6}');
      expect(countryFlagEmoji('US'), '\u{1F1FA}\u{1F1F8}');
    });

    test('accepts lowercase and surrounding whitespace', () {
      expect(countryFlagEmoji(' eg '), countryFlagEmoji('EG'));
    });

    test('returns null for anything that is not two ASCII letters', () {
      expect(countryFlagEmoji(''), isNull);
      expect(countryFlagEmoji('E'), isNull);
      expect(countryFlagEmoji('EGY'), isNull);
      expect(countryFlagEmoji('E1'), isNull);
      expect(countryFlagEmoji('مصر'), isNull);
    });
  });

  group('CountryModel.displayName', () {
    test('prefixes the flag when the code is valid', () {
      const country = CountryModel(id: 1, name: 'Egypt', code: 'EG');
      expect(country.displayName, '\u{1F1EA}\u{1F1EC}  Egypt');
    });

    test('falls back to the bare name when the code is missing', () {
      const country = CountryModel(id: 1, name: 'Egypt', code: '');
      expect(country.displayName, 'Egypt');
      expect(country.flag, isNull);
    });
  });
}
