import 'package:timeago/timeago.dart' as timeago;

/// Albanian relative-time messages — package:timeago ships none.
class SqMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'pas';
  @override
  String suffixAgo() => 'më parë';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'pak sekonda';
  @override
  String aboutAMinute(int minutes) => 'një minutë';
  @override
  String minutes(int minutes) => '$minutes minuta';
  @override
  String aboutAnHour(int minutes) => 'rreth një orë';
  @override
  String hours(int hours) => '$hours orë';
  @override
  String aDay(int hours) => 'një ditë';
  @override
  String days(int days) => '$days ditë';
  @override
  String aboutAMonth(int days) => 'rreth një muaj';
  @override
  String months(int months) => '$months muaj';
  @override
  String aboutAYear(int year) => 'rreth një vit';
  @override
  String years(int years) => '$years vjet';
  @override
  String wordSeparator() => ' ';
}
