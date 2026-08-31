import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/business_review.dart';
import 'package:need_mobile_app/models/review.dart';
import 'package:need_mobile_app/services/review_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class ReviewProvider extends ChangeNotifier{
  final ReviewService _service = ReviewService();

  List<Review> _myReviews = [];
  List<Review> get myReviews => _myReviews;

  List<BusinessReview> _businessReviews = [];
  List<BusinessReview> get businessReviews => _businessReviews;

  Review? _selectedReview;
  Review? get selectedReview => _selectedReview;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? get averageRating {
    if (_businessReviews.isEmpty) return null;
    final total = _businessReviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _businessReviews.length;
  }

  bool hasReviewedBooking(String bookingId) =>
      _myReviews.any((r) => r.bookingId == bookingId);

  Future<void> loadReviewsByBusiness(String businessId) async {
    _setLoading(true);
    try {
      _businessReviews = await _service.getAllReviewsByBusiness(businessId);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyReviews() async {
    _setLoading(true);
    try {
      _myReviews = await _service.getAllReviewsByUser();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReviewById(String id) async {
    _setLoading(true);
    try {
      _selectedReview = await _service.getReviewById(id);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    try {
      final review = await _service.createReview(
          bookingId: bookingId,
          rating: rating,
          comment: comment
      );
      _myReviews = [..._myReviews, review];
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReview(
    String id, {
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    try {
      final review = await _service.updateReview(
          id,
          rating: rating,
          comment: comment,
      );
      _replaceInCaches(review);
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReview(String id) async {
    _setLoading(true);
    try {
      await _service.deleteReview(id);

      _myReviews.removeWhere((r) => r.id == id);
      _businessReviews.removeWhere((r) => r.id == id);
      if (_selectedReview?.id == id) _selectedReview = null;

      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Review? reviewForBooking(String bookingId) {
    for (final r in _myReviews) {
      if (r.bookingId == bookingId) return r;
    }
    return null;
  }

  BusinessReview? reviewInBusinessAsync(String bookingId) {
    for (final r in _businessReviews) {
      if (r.bookingId == bookingId) return r;
    }
    return null;
  }

  void _replaceInCaches(Review updated) {
    if (_selectedReview?.id == updated.id) _selectedReview = updated;

    final myIndex = _myReviews.indexWhere((r) => r.id == updated.id);
    if (myIndex != -1) _myReviews[myIndex] = updated;

    final businessIndex = _businessReviews.indexWhere((r) => r.id == updated.id);
    if (businessIndex != -1) {
      _businessReviews[businessIndex] = _businessReviews[businessIndex].copyWithRatingAndComment(
        rating: updated.rating,
        comment: updated.comment,
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}