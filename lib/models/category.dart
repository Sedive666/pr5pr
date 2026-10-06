import 'entity.dart';
import 'json.dart';

class Category extends Entity {
  @override
  final int id;
  final String name;
  final String description;
  @override
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    this.description = '',
    this.deletedAt,
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: asInt(json['id']),
    name: asString(json['name']),
    description: asString(json['description']),
    deletedAt: asDate(json['deletedAt']),
  );
}
