import 'package:flutter/widgets.dart';

final _whitespace = RegExp(r'\s+');

String initialOf(String? name, {String fallback = '?'}) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return fallback;
  return trimmed.characters.first.toUpperCase();
}

String firstNameOf(String? fullName, {required String fallback}) {
  final trimmed = fullName?.trim() ?? '';
  if (trimmed.isEmpty) return fallback;
  return trimmed.split(_whitespace).first;
}
