class Category{
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.isActive
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isActive': isActive
  };

  Category copyWith({String? id, String? name, String? description, bool? isActive}) {
    return Category(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive
    );
  }
}