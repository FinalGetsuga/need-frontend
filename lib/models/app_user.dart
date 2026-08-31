class AppUser {
  final String id;
  final String? email;
  final String firstName;
  final String lastName;
  final String displayName;

  const AppUser({
    required this.id,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      displayName: json['displayName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'displayName': displayName,
  };
}