import 'package:intl/intl.dart';

final _calendarDateFormat = DateFormat('dd.MM.yyyy');

extension DateTimeExt on DateTime {
  String toCalendarDate() => _calendarDateFormat.format(this);
}
