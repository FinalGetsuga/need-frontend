import 'package:flutter/material.dart';
import 'enums.dart';
import 'parsing_helpers.dart';

class BusinessBooking {
  final String id;
  final String termId;
  final DateTime termDate;
  final TimeOfDay termStartTime;
  final TimeOfDay termEndTime;
  final String employeeId;
  final String employeeName;
  final String customerName;
  final BookingStatus status;
  final String? notes;
  final DateTime bookedAt;
  final String businessId;
  final String businessName;

  const BusinessBooking({
    required this.id,
    required this.termId,
    required this.termDate,
    required this.termStartTime,
    required this.termEndTime,
    required this.employeeId,
    required this.employeeName,
    required this.customerName,
    required this.status,
    this.notes,
    required this.bookedAt,
    required this.businessId,
    required this.businessName
  });

  factory BusinessBooking.fromJson(Map<String, dynamic> json) => BusinessBooking(
    id: json['id'] as String,
    termId: json['termId'] as String,
    termDate: DateTime.parse(json['termDate'] as String),
    termStartTime: parseTimeOfDay(json['termStartTime'] as String),
    termEndTime: parseTimeOfDay(json['termEndTime'] as String),
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    customerName: json['customerName'] as String,
    status: BookingStatus.fromInt(json['status'] as int),
    notes: json['notes'] as String?,
    bookedAt: DateTime.parse(json['bookedAt'] as String),
    businessId: json['businessId'] as String,
    businessName: json['businessName'] as String
  );

  BusinessBooking copyWithStatus(BookingStatus newStatus) => BusinessBooking(
    id: id,
    termId: termId,
    termDate: termDate,
    termStartTime: termStartTime,
    termEndTime: termEndTime,
    employeeId: employeeId,
    employeeName: employeeName,
    customerName: customerName,
    status: newStatus,
    notes: notes,
    bookedAt: bookedAt,
    businessId: businessId,
    businessName: businessName
  );
}