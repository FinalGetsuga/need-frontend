import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/business_booking.dart';
import 'package:need_mobile_app/providers/auth_provider.dart';
import 'package:need_mobile_app/providers/booking_provider.dart';
import 'package:need_mobile_app/screens/booking/booking_detail_screen.dart';
import 'package:need_mobile_app/widgets/business_booking_card.dart';
import 'package:need_mobile_app/widgets/login_prompt.dart';
import 'package:provider/provider.dart';

class BookingsTabScreen extends StatefulWidget {
  const BookingsTabScreen({super.key});

  @override
  State<BookingsTabScreen> createState() => _BookingsTabScreenState();
}

class _BookingsTabScreenState extends State<BookingsTabScreen> {
  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthProvider>().isSignedIn) {
      return const LoginPrompt(message: 'Log in to see your bookings.');
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.myBookings.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null && provider.myBookings.isEmpty) {
              return Center(child: Text(provider.errorMessage!));
            }
            return TabBarView(
              children: [
                _BookingList(bookings: provider.upcomingBookings),
                _BookingList(bookings: provider.completedBookings),
                _BookingList(bookings: provider.cancelledBookings),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BusinessBooking> bookings;
  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(child: Text('Nothing here yet.', style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BusinessBookingCard(
          booking: booking,
          showBusinessName: true,
          showCustomerName: false,
          onCancel: () => _confirmCancel(context, booking.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking, canReview: true)),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking?'),
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
}