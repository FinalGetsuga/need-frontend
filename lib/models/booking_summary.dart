import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/parsing_helpers.dart';

class BookingSummary {
  final String id;
  final DateTime termDate;
  final TimeOfDay termStartTime;
  final String businessId;
  final String businessName;

  const BookingSummary({
    required this.id,
    required this.termDate,
    required this.termStartTime,
    required this.businessId,
    required this.businessName,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) => BookingSummary(
      id: json['id'] as String,
      termDate: DateTime.parse(json['termDate'] as String),
      termStartTime: parseTimeOfDay(json['termStartTime'] as String),
      businessId: json['businessId'] as String,
      businessName: json['businessName'] as String,
  );
}