import 'package:timeago/timeago.dart' as timeago;

/// Uzbek (Latin) relative-time messages — package:timeago ships none.
class UzMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'oldin';
  @override
  String suffixFromNow() => 'keyin';
  @override
  String lessThanOneMinute(int seconds) => 'hozirgina';
  @override
  String aboutAMinute(int minutes) => 'bir daqiqa';
  @override
  String minutes(int minutes) => '$minutes daqiqa';
  @override
  String aboutAnHour(int minutes) => 'taxminan bir soat';
  @override
  String hours(int hours) => '$hours soat';
  @override
  String aDay(int hours) => 'bir kun';
  @override
  String days(int days) => '$days kun';
  @override
  String aboutAMonth(int days) => 'taxminan bir oy';
  @override
  String months(int months) => '$months oy';
  @override
  String aboutAYear(int year) => 'taxminan bir yil';
  @override
  String years(int years) => '$years yil';
  @override
  String wordSeparator() => ' ';
}
