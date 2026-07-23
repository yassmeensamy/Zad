const int _regionalIndicatorA = 0x1F1E6;
const int _letterA = 0x41;
const int _letterZ = 0x5A;

String? countryFlagEmoji(String code) {
  final normalized = code.trim().toUpperCase();
  if (normalized.length != 2) return null;

  final buffer = StringBuffer();
  for (final unit in normalized.codeUnits) {
    if (unit < _letterA || unit > _letterZ) return null;
    buffer.writeCharCode(_regionalIndicatorA + (unit - _letterA));
  }
  return buffer.toString();
}
