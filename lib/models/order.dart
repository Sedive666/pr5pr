import 'entity.dart';
import 'json.dart';

const orderStatuses = ['Новый', 'Оплачен', 'Отправлен', 'Доставлен', 'Отменён'];

class Order extends Entity {
  @override
  final int id;
  final String number;
  final int customerId;
  final int sneakerId;
  final int size;
  final int quantity;
  final int price;
  final String status;
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;

  const Order({
    required this.id,
    required this.number,
    required this.customerId,
    required this.sneakerId,
    required this.size,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
    this.deletedAt,
  });

  int get total => price * quantity;

  Order copyWith({
    int? id,
    String? number,
    int? customerId,
    int? sneakerId,
    int? size,
    int? quantity,
    int? price,
    String? status,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Order(
      id: id ?? this.id,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      sneakerId: sneakerId ?? this.sneakerId,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'customerId': customerId,
    'sneakerId': sneakerId,
    'size': size,
    'quantity': quantity,
    'price': price,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    final status = asString(json['status']);
    return Order(
      id: asInt(json['id']),
      number: asString(json['number']),
      customerId: asInt(json['customerId']),
      sneakerId: asInt(json['sneakerId']),
      size: asInt(json['size']),
      quantity: asInt(json['quantity'], 1),
      price: asInt(json['price']),
      status: orderStatuses.contains(status) ? status : orderStatuses.first,
      createdAt: asDate(json['createdAt']) ?? DateTime(2025),
      deletedAt: asDate(json['deletedAt']),
    );
  }
}
