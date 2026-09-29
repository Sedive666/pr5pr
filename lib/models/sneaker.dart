import 'entity.dart';

class Sneaker extends Entity {
  @override
  final int id;
  final String name;
  final String sku;
  final int year;
  final int price;
  final int brandId;
  final int seriesId;
  final int categoryId;
  final int stockTotal;
  final int stockAvailable;
  @override
  final DateTime? deletedAt;

  const Sneaker({
    required this.id,
    required this.name,
    required this.sku,
    required this.year,
    required this.price,
    required this.brandId,
    required this.seriesId,
    required this.categoryId,
    required this.stockTotal,
    required this.stockAvailable,
    this.deletedAt,
  });

  Sneaker copyWith({
    int? id,
    String? name,
    String? sku,
    int? year,
    int? price,
    int? brandId,
    int? seriesId,
    int? categoryId,
    int? stockTotal,
    int? stockAvailable,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Sneaker(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      year: year ?? this.year,
      price: price ?? this.price,
      brandId: brandId ?? this.brandId,
      seriesId: seriesId ?? this.seriesId,
      categoryId: categoryId ?? this.categoryId,
      stockTotal: stockTotal ?? this.stockTotal,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
