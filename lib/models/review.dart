import 'entity.dart';
import 'json.dart';

class Review extends Entity {
  @override
  final int id;
  final int customerId;
  final int sneakerId;
  final int rating;
  final String text;
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;

  const Review({
    required this.id,
    required this.customerId,
    required this.sneakerId,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.deletedAt,
  });

  Review copyWith({
    int? id,
    int? customerId,
    int? sneakerId,
    int? rating,
    String? text,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Review(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      sneakerId: sneakerId ?? this.sneakerId,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'sneakerId': sneakerId,
    'rating': rating,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: asInt(json['id']),
    customerId: asInt(json['customerId']),
    sneakerId: asInt(json['sneakerId']),
    rating: asInt(json['rating'], 5).clamp(1, 5),
    text: asString(json['text']),
    createdAt: asDate(json['createdAt']) ?? DateTime(2025),
    deletedAt: asDate(json['deletedAt']),
  );
}
