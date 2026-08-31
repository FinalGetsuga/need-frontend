class BookableEmployee {
  final String id;
  final String firstName;
  final String lastName;

  const BookableEmployee({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory BookableEmployee.fromJson(Map<String, dynamic> json) => BookableEmployee(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String
  );
}