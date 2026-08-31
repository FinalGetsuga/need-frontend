import 'package:flutter/material.dart';
import '../models/business_booking.dart';
import '../models/enums.dart';
import 'booking_status_pill.dart';

class BusinessBookingCard extends StatelessWidget {
  final BusinessBooking booking;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;
  final bool showEmployeeName;
  final bool showCustomerName;
  final bool showBusinessName;

  const BusinessBookingCard({
    super.key, required this.booking, this.onCancel, this.onTap,
    this.showEmployeeName = true, this.showCustomerName = true, this.showBusinessName = false,
  });

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBusinessName) ...[
                Text(booking.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BookingStatusPill(status: booking.status),
                  Text('${_formatDate(booking.termDate)} · ${booking.termStartTime.format(context)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              if (showCustomerName) ...[
                Row(children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('Customer: ${booking.customerName}', style: const TextStyle(fontSize: 13)),
                ]),
                const SizedBox(height: 4),
              ],
              if (showEmployeeName)
                Row(children: [
                  Icon(Icons.badge_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('With: ${booking.employeeName}', style: const TextStyle(fontSize: 13)),
                ]),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(booking.notes!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
              if (onCancel != null && booking.status == BookingStatus.confirmed) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: onCancel, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Cancel')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}