import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/booking.dart';
import 'package:need_mobile_app/models/booking_summary.dart';
import 'package:need_mobile_app/models/business_booking.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/services/booking_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class BookingProvider extends ChangeNotifier{
  final BookingService _service = BookingService();

  List<BusinessBooking> _myBookings = [];
  List<BusinessBooking> get myBookings => _myBookings;

  List<BusinessBooking> _businessBookings = [];
  List<BusinessBooking> get businessBookings => _businessBookings;

  List<BusinessBooking> _myEmployeeBookings = [];
  List<BusinessBooking> get myEmployeeBookings => _myEmployeeBookings;

  Booking? _selectedBooking;
  Booking? get selectedBooking => _selectedBooking;

  BookingSummary? _upcomingBookingSummary;
  BookingSummary? get upcomingBookingSummary => _upcomingBookingSummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// FOR USER
  List<BusinessBooking> get upcomingBookings {
    final list = _myBookings.where((b) => b.status == BookingStatus.confirmed).toList();
    list.sort((a,b) => _termDateTime(a).compareTo(_termDateTime(b)));
    return list;
  }

  List<BusinessBooking> get completedBookings =>
      _myBookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BusinessBooking> get cancelledBookings =>
      _myBookings.where((b) => b.status == BookingStatus.cancelledByCustomer || b.status == BookingStatus.cancelledByBusiness).toList();

  DateTime _termDateTime(BusinessBooking b) => b.termDate.add(Duration(hours: b.termStartTime.hour, minutes: b.termStartTime.minute));

  /// FOR EMPLOYEE
  List<BusinessBooking> get myEmployeeUpcomingBookings {
    final list = _myEmployeeBookings.where((b) => b.status == BookingStatus.confirmed).toList();
    list.sort((a,b) => _termDateTime(a).compareTo(_termDateTime(b)));
    return list;
  }

  List<BusinessBooking> get myEmployeeCompletedBookings =>
      _myEmployeeBookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BusinessBooking> get myEmployeeCancelledBookings =>
      _myEmployeeBookings.where((b) => b.status == BookingStatus.cancelledByCustomer || b.status == BookingStatus.cancelledByBusiness).toList();

  Future<void> loadMyBookings() async {
    _setLoading(true);
    try {
      _myBookings = await _service.getAllBookingsByUser();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNextUpcomingBooking() async {
    try {
      _upcomingBookingSummary = await _service.getNextUpcomingBooking();
    }on ApiException catch(_) {
      _upcomingBookingSummary = null;
    }
    notifyListeners();
  }

  Future<void> loadBookingsByBusiness(String businessId) async {
    _setLoading(true);
    try {
      _businessBookings = await _service.getAllBookingsByBusiness(businessId);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyEmployeeBookings() async {
    _setLoading(true);
    try {
      _myEmployeeBookings = await _service.getMyEmployeeBookings();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBookingById(String id) async {
    _setLoading(true);
    try {
      _selectedBooking = await _service.getBookingById(id);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBooking({
    required String termId,
    String? notes
  }) async {
    try {
       await _service.createBooking(
          termId: termId,
          notes: notes
      );
      await loadMyBookings();
      await loadNextUpcomingBooking();
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelBooking(String id) async {
    _setLoading(true);
    try {
      final cancelled = await _service.cancelBooking(id);
      _replaceInCaches(cancelled);
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _replaceInCaches(Booking updated) {
    if (_selectedBooking?.id == updated.id) _selectedBooking = updated;

    final myIndex = _myBookings.indexWhere((b) => b.id == updated.id);
    if (myIndex != -1) _myBookings[myIndex] = _myBookings[myIndex].copyWithStatus(updated.status);

    final businessIndex = _businessBookings.indexWhere((b) => b.id == updated.id);
    if (businessIndex != -1) {
      _businessBookings[businessIndex] = _businessBookings[businessIndex].copyWithStatus(updated.status);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearUserBookings() {
    _myBookings = [];
    _upcomingBookingSummary = null;
    notifyListeners();
  }
}