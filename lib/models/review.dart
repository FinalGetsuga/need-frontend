class Review {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;

  const Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'rating': rating,
    'comment': comment,
  };

  Review copyWith({
    String? id,
    String? bookingId,
    int? rating,
    String? comment
  }) {
    return Review(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment
    );
  }
}