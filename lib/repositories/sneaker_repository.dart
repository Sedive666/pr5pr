import '../data/seed.dart';
import '../models/sneaker.dart';
import '../models/sneaker_query.dart';
import 'entity_repository.dart';
import 'in_memory_repository.dart';

abstract interface class SneakerRepository
    implements EntityRepository<Sneaker, SneakerQuery> {}

class InMemorySneakerRepository
    extends InMemoryRepository<Sneaker, SneakerQuery>
    implements SneakerRepository {
  InMemorySneakerRepository({List<Sneaker>? seed, super.delay})
    : super(seed ?? seedSneakers);

  @override
  bool matches(Sneaker s, SneakerQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty ||
            s.name.toLowerCase().contains(needle) ||
            s.sku.toLowerCase().contains(needle)) &&
        (q.categoryId == null || s.categoryId == q.categoryId) &&
        (q.brandId == null || s.brandId == q.brandId) &&
        (q.yearFrom == null || s.year >= q.yearFrom!) &&
        (q.yearTo == null || s.year <= q.yearTo!);
  }

  @override
  int compareBy(String field, Sneaker a, Sneaker b) => switch (field) {
    'year' => a.year.compareTo(b.year),
    'price' => a.price.compareTo(b.price),
    'stock' => a.stockAvailable.compareTo(b.stockAvailable),
    _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  };

  @override
  Sneaker withDeletedAt(Sneaker item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Sneaker withId(Sneaker item, int id) => item.copyWith(id: id);
}
