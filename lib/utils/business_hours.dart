import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/models/work_schedule.dart';
import 'package:need_mobile_app/models/working_day.dart';

class BusinessOpenStatus {
  final bool isOpen;
  final String label;
  const BusinessOpenStatus({
    required this.isOpen,
    required this.label
  });
}

const _weekdayNames = {
  AppDayOfWeek.monday: 'Monday',
  AppDayOfWeek.tuesday: 'Tuesday',
  AppDayOfWeek.wednesday: 'Wednesday',
  AppDayOfWeek.thursday: 'Thursday',
  AppDayOfWeek.friday: 'Friday',
  AppDayOfWeek.saturday: 'Saturday',
  AppDayOfWeek.sunday: 'Sunday',
};

String weekdayName(AppDayOfWeek day) => _weekdayNames[day]!;

AppDayOfWeek _appDayOfWeekFrom(DateTime dt) => AppDayOfWeek.values[dt.weekday % 7];

BusinessOpenStatus? computeOpenStatus(WorkSchedule schedule, BuildContext context) {
  if (schedule.workingDays.isEmpty) return null;

  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;

  WorkingDay? findEntry(AppDayOfWeek day) {
    for (final d in schedule.workingDays) {
      if (d.dayOfWeek == day) return d;
    }
    return null;
  }

  final todayEntry = findEntry(_appDayOfWeekFrom(now));

  if (todayEntry != null) {
    final startMin = todayEntry.startTime.hour * 60 + todayEntry.startTime.minute;
    final endMin = todayEntry.endTime.hour * 60 + todayEntry.endTime.minute;

    if (nowMinutes >= startMin && nowMinutes < endMin) {
      return BusinessOpenStatus(isOpen: true, label: 'Closes at ${todayEntry.endTime.format(context)}');
    }
    if (nowMinutes < startMin) {
      return BusinessOpenStatus(isOpen: false, label: 'Opens today at ${todayEntry.startTime.format(context)}');
    }
  }

  for (int i = 1; i <= 6; i++) {
    final futureDate = now.add(Duration(days: i));
    final entry = findEntry(_appDayOfWeekFrom(futureDate));
    if (entry != null) {
      final dayLabel = i == 1 ? 'tomorrow' : weekdayName(_appDayOfWeekFrom(futureDate));
      return BusinessOpenStatus(isOpen: false, label: 'Opens $dayLabel at ${entry.startTime.format(context)}');
    }
  }

  return const BusinessOpenStatus(isOpen: false, label: 'Closed');
}