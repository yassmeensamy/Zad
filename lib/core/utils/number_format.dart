import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_languages.dart';

String groupedNumber(BuildContext context, int n) =>
    _formatterFor(context.appLanguage.code).format(n);

final Map<String, NumberFormat> _formatters = {};

NumberFormat _formatterFor(String languageCode) =>
    _formatters[languageCode] ??= NumberFormat.decimalPattern(languageCode);
