class Employee {
  final String id;
  final String businessId;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  const Employee({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      isActive: json['isActive'] as bool
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessId': businessId,
    'userId': userId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'isActive': isActive
  };

  String get displayName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive
  }) {
    return Employee(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        userId: userId ?? this.userId,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isActive: isActive ?? this.isActive
    );
  }
}