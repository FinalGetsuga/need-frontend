class Employment {
  final String employeeId;
  final String businessId;
  final String businessName;

  const Employment({
    required this.employeeId,
    required this.businessId,
    required this.businessName,
  });

  factory Employment.fromJson(Map<String, dynamic> json) => Employment(
      employeeId: json['employeeId'] as String,
      businessId: json['businessId'] as String,
      businessName: json['businessName'] as String
  );
}