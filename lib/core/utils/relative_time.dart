import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../l10n/app_languages.dart';

String? formatRelative(BuildContext context, DateTime? date) {
  if (date == null) return null;
  // `main` registers timeago messages for every code in [AppLanguages], so the
  // active language always resolves; unknown codes fall back to English.
  return timeago.format(date, locale: context.appLanguage.code);
}
