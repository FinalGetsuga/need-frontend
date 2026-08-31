import 'package:flutter/material.dart';
import 'package:need_mobile_app/screens/booking/booking_detail_screen.dart';
import 'package:need_mobile_app/widgets/business_booking_card.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';

class BusinessBookingsScreen extends StatefulWidget {
  final String businessId;
  const BusinessBookingsScreen({super.key, required this.businessId});

  @override
  State<BusinessBookingsScreen> createState() => _BusinessBookingsScreenState();
}

class _BusinessBookingsScreenState extends State<BusinessBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookingsByBusiness(widget.businessId);
    });
  }

  Future<void> _confirmCancel(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text('The customer will be notified their appointment was cancelled by the business.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<BookingProvider>().cancelBooking(bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Business Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(BookingProvider provider) {
    if (provider.isLoading && provider.businessBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.businessBookings.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(provider.errorMessage!, textAlign: TextAlign.center)));
    }
    if (provider.businessBookings.isEmpty) {
      return Center(child: Text('No bookings yet.', style: TextStyle(color: Colors.grey.shade600)));
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBookingsByBusiness(widget.businessId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.businessBookings.length,
        itemBuilder: (context, index) {
          final booking = provider.businessBookings[index];
          return BusinessBookingCard(
              booking: booking,
              onCancel: () => _confirmCancel(context, booking.id),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking))),
          );
        },
      ),
    );
  }
}