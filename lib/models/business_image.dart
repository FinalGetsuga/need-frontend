class BusinessImage {
  final String id;
  final String imageUrl;
  final int displayOrder;

  const BusinessImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder
  });

  factory BusinessImage.fromJson(Map<String, dynamic> json) => BusinessImage(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int
  );
}