class BusinessReview {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;
  final String customerName;

  const BusinessReview({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.customerName
  });

  factory BusinessReview.fromJson(Map<String, dynamic> json) => BusinessReview(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      customerName: json['customerName'] as String
  );

  BusinessReview copyWithRatingAndComment({required int rating, String? comment}) => BusinessReview(
    id: id,
    bookingId: bookingId,
    rating: rating,
    comment: comment,
    customerName: customerName,
  );
}