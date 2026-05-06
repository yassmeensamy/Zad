import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

String? formatRelative(BuildContext context, DateTime? date) {
  if (date == null) return null;
  final locale = context.locale.languageCode == 'ar' ? 'ar' : 'en';
  return timeago.format(date, locale: locale);
}
