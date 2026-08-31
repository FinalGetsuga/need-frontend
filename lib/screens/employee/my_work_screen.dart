import 'package:flutter/material.dart';
import 'package:need_mobile_app/screens/booking/booking_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../models/business_booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/business_booking_card.dart';

class MyWorkScreen extends StatefulWidget {
  final String businessId;
  final String businessName;
  const MyWorkScreen({super.key, required this.businessId, required this.businessName});

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadMyEmployeeBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(widget.businessName),
          bottom: const TabBar(tabs: [Tab(text: 'Upcoming'), Tab(text: 'Completed'), Tab(text: 'Cancelled')]),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.myEmployeeBookings.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null && provider.myEmployeeBookings.isEmpty) {
              return Center(child: Text(provider.errorMessage!));
            }
            return TabBarView(
              children: [
                _BookingList(bookings: provider.myEmployeeUpcomingBookings),
                _BookingList(bookings: provider.myEmployeeCompletedBookings),
                _BookingList(bookings: provider.myEmployeeCancelledBookings),
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
      itemBuilder: (context, index) => BusinessBookingCard(
          booking: bookings[index],
          showEmployeeName: false,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: bookings[index])))
      ),
    );
  }
}