import 'entity.dart';
import 'json.dart';

const cardLevels = ['Серебряная', 'Золотая', 'Платиновая'];

class LoyaltyCard {
  final String number;
  final String level;
  final int bonusPoints;
  final DateTime issuedAt;

  const LoyaltyCard({
    required this.number,
    required this.level,
    required this.bonusPoints,
    required this.issuedAt,
  });

  LoyaltyCard copyWith({
    String? number,
    String? level,
    int? bonusPoints,
    DateTime? issuedAt,
  }) {
    return LoyaltyCard(
      number: number ?? this.number,
      level: level ?? this.level,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      issuedAt: issuedAt ?? this.issuedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'level': level,
    'bonusPoints': bonusPoints,
    'issuedAt': issuedAt.toIso8601String(),
  };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    final level = asString(json['level']);
    return LoyaltyCard(
      number: asString(json['number']),
      level: cardLevels.contains(level) ? level : cardLevels.first,
      bonusPoints: asInt(json['bonusPoints']),
      issuedAt: asDate(json['issuedAt']) ?? DateTime(2024),
    );
  }
}

class Customer extends Entity {
  @override
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String city;
  final LoyaltyCard? card;
  @override
  final DateTime? deletedAt;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    this.card,
    this.deletedAt,
  });

  String get fullName => '$lastName $firstName';

  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    LoyaltyCard? card,
    bool clearCard = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      card: clearCard ? null : (card ?? this.card),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'city': city,
    'card': card?.toJson(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) {
    final card = json['card'];
    return Customer(
      id: asInt(json['id']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      email: asString(json['email']),
      phone: asString(json['phone']),
      city: asString(json['city']),
      card: card == null ? null : LoyaltyCard.fromJson(asMap(card)),
      deletedAt: asDate(json['deletedAt']),
    );
  }
}
