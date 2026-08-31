import 'package:need_mobile_app/models/booking.dart';
import 'package:need_mobile_app/models/booking_summary.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

import '../models/business_booking.dart';

class BookingService extends BaseApiService {

  Future<Booking> getBookingById(String id) async {
    final response = await get(ApiEndpoints.getBookingById(id));
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingSummary?> getNextUpcomingBooking() async {
    var response = await get(ApiEndpoints.getNextUpcomingBooking);
    if (response.data == null) return null;
    return BookingSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BusinessBooking>> getAllBookingsByBusiness(String businessId) async {
    var response = await get(ApiEndpoints.getAllBookingsByBusinessId(businessId));
    return (response.data as List)
        .map((e) => BusinessBooking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BusinessBooking>> getMyEmployeeBookings() async {
    var response = await get(ApiEndpoints.getMyEmployeeBookings);
    return (response.data as List)
        .map((e) => BusinessBooking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BusinessBooking>> getAllBookingsByUser() async {
    final response = await get(ApiEndpoints.getMineBookings);
    return (response.data as List)
        .map((e) => BusinessBooking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> createBooking({
      required String termId,
      String? notes,
  }) async {
    final response = await post(ApiEndpoints.createBooking, {
      'termId': termId,
      'notes': notes,
    });
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> cancelBooking(String id) async {
    final response = await put(ApiEndpoints.cancelBooking(id));
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }
}