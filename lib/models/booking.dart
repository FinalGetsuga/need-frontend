import 'package:need_mobile_app/models/enums.dart';

class Booking {
  final String id;
  final String termId;
  final String customerId;
  final BookingStatus status;
  final String? notes;
  final DateTime bookedAt;

  const Booking({
    required this.id,
    required this.termId,
    required this.customerId,
    required this.status,
    this.notes,
    required this.bookedAt
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
      id: json['id'] as String,
      termId: json['termId'] as String,
      customerId: json['customerId'] as String,
      status: BookingStatus.fromInt(json['status'] as int),
      notes: json['notes'] as String?,
      bookedAt: DateTime.parse(json['bookedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'termId': termId,
    'customerId': customerId,
    'status': status.toInt(),
    'notes': notes,
    'bookedAt': bookedAt.toIso8601String(),
  };

  Booking copyWith({
    String? id,
    String? termId,
    String? customerId,
    BookingStatus? status,
    String? notes,
    DateTime? bookedAt,
  }) {
    return Booking(
        id: id ?? this.id,
        termId: termId ?? this.termId,
        customerId: customerId ?? this.customerId,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}