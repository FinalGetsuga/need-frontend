import 'package:flutter/material.dart';
import '../models/enums.dart';

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;
  const BookingStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.confirmed => ('Confirmed', Colors.blue),
      BookingStatus.completed => ('Completed', Colors.green),
      BookingStatus.cancelledByCustomer => ('Cancelled by customer', Colors.grey),
      BookingStatus.cancelledByBusiness => ('Cancelled by business', Colors.orange),
      BookingStatus.noShow => ('No-show', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}