import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/models/parsing_helpers.dart';

class WorkingDay {
  final String id;
  final String workScheduleId;
  final AppDayOfWeek dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const WorkingDay({
    required this.id,
    required this.workScheduleId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) => WorkingDay(
      id: json['id'] as String,
      workScheduleId: json['workScheduleId'] as String,
      dayOfWeek: AppDayOfWeek.fromInt(json['dayOfWeek'] as int),
      startTime: parseTimeOfDay(json['startTime'] as String),
      endTime: parseTimeOfDay(json['endTime'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workScheduleId': workScheduleId,
    'dayOfWeek': dayOfWeek.toInt(),
    'startTime': formatTimeOfDay(startTime),
    'endTime': formatTimeOfDay(endTime),
  };

  WorkingDay copyWith({
    String? id,
    String? workScheduleId,
    AppDayOfWeek? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return WorkingDay(
        id: id ?? this.id,
        workScheduleId: workScheduleId ?? this.workScheduleId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
    );
  }
}