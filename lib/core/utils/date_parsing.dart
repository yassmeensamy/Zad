DateTime? parseIsoDate(dynamic value, {bool toLocal = true}) {
  if (value is! String || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return toLocal ? parsed.toLocal() : parsed;
}
