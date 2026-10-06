import 'entity.dart';
import 'json.dart';

class Brand extends Entity {
  @override
  final int id;
  final String name;
  final String country;
  final int foundedYear;
  @override
  final DateTime? deletedAt;

  const Brand({
    required this.id,
    required this.name,
    required this.country,
    required this.foundedYear,
    this.deletedAt,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? country,
    int? foundedYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'foundedYear': foundedYear,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: asInt(json['id']),
    name: asString(json['name']),
    country: asString(json['country']),
    foundedYear: asInt(json['foundedYear']),
    deletedAt: asDate(json['deletedAt']),
  );
}
