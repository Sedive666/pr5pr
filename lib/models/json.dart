int asInt(Object? v, [int fallback = 0]) => switch (v) {
  int i => i,
  num n => n.toInt(),
  String s => int.tryParse(s) ?? fallback,
  _ => fallback,
};

String asString(Object? v, [String fallback = '']) =>
    v is String ? v : (v == null ? fallback : '$v');

List<int> asIntList(Object? v) =>
    v is List ? v.map((e) => asInt(e)).where((e) => e > 0).toList() : const [];

DateTime? asDate(Object? v) => v is String ? DateTime.tryParse(v) : null;

Map<String, dynamic> asMap(Object? v) =>
    v is Map ? v.map((k, e) => MapEntry('$k', e)) : const {};
