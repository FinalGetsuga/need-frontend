import 'package:need_mobile_app/models/business_image.dart';

class Business {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? logoUrl;
  final String? websiteUrl;
  final String categoryId;
  final double? rating;
  final int reviewCount;
  final List<BusinessImage> images;

  const Business({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.logoUrl,
    this.websiteUrl,
    required this.categoryId,
    this.rating,
    required this.reviewCount,
    this.images = const [],
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    address: json['address'] as String,
    logoUrl: json['logoUrl'] as String?,
    websiteUrl: json['websiteUrl'] as String?,
    categoryId: json['categoryId'] as String,
    rating: (json['rating'] as num?)?.toDouble(),
    reviewCount: json['reviewCount'] as int,
    images: json['images'] == null
        ? const []
        : (json['images'] as List<dynamic>).map((e) => BusinessImage.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'logoUrl': logoUrl,
    'websiteUrl': websiteUrl,
    'categoryId': categoryId,
    'rating': rating,
    'reviewCount': reviewCount
  };

  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? logoUrl,
    String? websiteUrl,
    String? categoryId,
    double? rating,
    int? reviewCount,
    List<BusinessImage>? images,
  }) {
    return Business(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        logoUrl: logoUrl ?? this.logoUrl,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        categoryId: categoryId ?? this.categoryId,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        images: images ?? this.images,
    );
  }
}