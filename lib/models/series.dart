import 'entity.dart';

class Series extends Entity {
  @override
  final int id;
  final String name;
  final int brandId;
  final String country;
  final int launchYear;
  @override
  final DateTime? deletedAt;

  const Series({
    required this.id,
    required this.name,
    required this.brandId,
    required this.country,
    required this.launchYear,
    this.deletedAt,
  });

  Series copyWith({
    int? id,
    String? name,
    int? brandId,
    String? country,
    int? launchYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Series(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      country: country ?? this.country,
      launchYear: launchYear ?? this.launchYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
