import 'package:timeago/timeago.dart' as timeago;

/// Kazakh (Cyrillic) relative-time messages — package:timeago ships none.
class KkMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'бұрын';
  @override
  String suffixFromNow() => 'кейін';
  @override
  String lessThanOneMinute(int seconds) => 'жаңа ғана';
  @override
  String aboutAMinute(int minutes) => 'бір минут';
  @override
  String minutes(int minutes) => '$minutes минут';
  @override
  String aboutAnHour(int minutes) => 'шамамен бір сағат';
  @override
  String hours(int hours) => '$hours сағат';
  @override
  String aDay(int hours) => 'бір күн';
  @override
  String days(int days) => '$days күн';
  @override
  String aboutAMonth(int days) => 'шамамен бір ай';
  @override
  String months(int months) => '$months ай';
  @override
  String aboutAYear(int year) => 'шамамен бір жыл';
  @override
  String years(int years) => '$years жыл';
  @override
  String wordSeparator() => ' ';
}
