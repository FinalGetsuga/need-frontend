import 'package:need_mobile_app/models/business_review.dart';
import 'package:need_mobile_app/models/review.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

class ReviewService extends BaseApiService {

  Future<Review> getReviewById(String id) async {
    var response = await get(ApiEndpoints.getReviewById(id));
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BusinessReview>> getAllReviewsByBusiness(String id) async {
    var response = await get(ApiEndpoints.getAllReviewsByBusiness(id));
    return (response.data as List)
        .map((e) => BusinessReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> getAllReviewsByUser() async {
    var response = await get(ApiEndpoints.getMineReviews);
    return (response.data as List)
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Review> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');
    var response = await post(ApiEndpoints.createReview, {
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Review> updateReview(
    String id, {
    required int rating,
    String? comment,
  }) async {
    var response = await put(ApiEndpoints.updateReview(id), {
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Review> deleteReview(String id) async {
    var response = await delete(ApiEndpoints.deleteReview(id));
    return Review.fromJson(response.data as Map<String, dynamic>);
  }
}