import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/models/parsing_helpers.dart';
import 'package:need_mobile_app/models/working_day.dart';

class WorkSchedule {
  final String id;
  final String businessId;
  final int termDurationMinutes;
  final List<WorkingDay> workingDays;

  const WorkSchedule({
    required this.id,
    required this.businessId,
    required this.termDurationMinutes,
    required this.workingDays,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) => WorkSchedule(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      termDurationMinutes: json['termDurationMinutes'] as int,
      workingDays: (json['workingDays'] as List<dynamic>)
        .map((e) => WorkingDay.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessId': businessId,
    'termDurationMinutes': termDurationMinutes,
    'workingDays': workingDays.map((e) => e.toJson()).toList(),
  };

  WorkSchedule copyWith({
    String? id,
    String? businessId,
    int? termDurationMinutes,
    List<WorkingDay>? workingDays,
  }) {
    return WorkSchedule(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        termDurationMinutes: termDurationMinutes ?? this.termDurationMinutes,
        workingDays: workingDays ?? this.workingDays
    );
  }
}

class WorkingDayInput {
  final AppDayOfWeek dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const WorkingDayInput({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek.toInt(),
    'startTime': formatTimeOfDay(startTime),
    'endTime': formatTimeOfDay(endTime),
  };
}

