import '../models/entity.dart';

String nameOf<T extends Entity>(
  List<T> items,
  int id,
  String Function(T) label,
) {
  for (final item in items) {
    if (item.id == id) return label(item);
  }
  return '—';
}

String namesOf<T extends Entity>(
  List<T> items,
  List<int> ids,
  String Function(T) label,
) {
  final names = [
    for (final item in items)
      if (ids.contains(item.id)) label(item),
  ];
  return names.isEmpty ? '—' : names.join(', ');
}
