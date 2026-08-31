import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/models/parsing_helpers.dart';

class Term {
  final String id;
  final String employeeId;
  final String businessId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TermStatus status;

  const Term({
    required this.id,
    required this.employeeId,
    required this.businessId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      businessId: json['businessId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: parseTimeOfDay(json['startTime'] as String),
      endTime: parseTimeOfDay(json['endTime'] as String),
      status: TermStatus.fromInt(json['status'] as int),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'businessId': businessId,
    'date': formatDateOnly(date),
    'startTime': formatTimeOfDay(startTime),
    'endTime': formatTimeOfDay(endTime),
    'status': status.toInt(),
  };

  Term copyWith({
    String? id,
    String? employeeId,
    String? businessId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    TermStatus? status,
  }) {
    return Term(
        id: id ?? this.id,
        employeeId: employeeId ?? this.employeeId,
        businessId: businessId ?? this.businessId,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status
    );
  }
}
