import 'entity.dart';
import 'json.dart';

class Sneaker extends Entity {
  @override
  final int id;
  final String name;
  final String sku;
  final int year;
  final int price;
  final int brandId;
  final List<int> seriesIds;
  final List<int> categoryIds;
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
    this.seriesIds = const [],
    this.categoryIds = const [],
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
    List<int>? seriesIds,
    List<int>? categoryIds,
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
      seriesIds: seriesIds ?? this.seriesIds,
      categoryIds: categoryIds ?? this.categoryIds,
      stockTotal: stockTotal ?? this.stockTotal,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'year': year,
    'price': price,
    'brandId': brandId,
    'seriesIds': seriesIds,
    'categoryIds': categoryIds,
    'stockTotal': stockTotal,
    'stockAvailable': stockAvailable,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Sneaker.fromJson(Map<String, dynamic> json) => Sneaker(
    id: asInt(json['id']),
    name: asString(json['name']),
    sku: asString(json['sku']),
    year: asInt(json['year']),
    price: asInt(json['price']),
    brandId: asInt(json['brandId']),
    seriesIds: asIntList(json['seriesIds']),
    categoryIds: asIntList(json['categoryIds']),
    stockTotal: asInt(json['stockTotal']),
    stockAvailable: asInt(json['stockAvailable']),
    deletedAt: asDate(json['deletedAt']),
  );
}
