import '../data/seed.dart';
import '../models/series.dart';
import '../models/series_query.dart';
import 'entity_repository.dart';
import 'in_memory_repository.dart';

abstract interface class SeriesRepository
    implements EntityRepository<Series, SeriesQuery> {}

class InMemorySeriesRepository extends InMemoryRepository<Series, SeriesQuery>
    implements SeriesRepository {
  InMemorySeriesRepository({List<Series>? seed, super.delay})
    : super(seed ?? seedSeries);

  @override
  bool matches(Series s, SeriesQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty ||
            s.name.toLowerCase().contains(needle) ||
            s.country.toLowerCase().contains(needle)) &&
        (q.brandId == null || s.brandId == q.brandId);
  }

  @override
  int compareBy(String field, Series a, Series b) => switch (field) {
    'year' => a.launchYear.compareTo(b.launchYear),
    'country' => a.country.compareTo(b.country),
    _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  };

  @override
  Series withDeletedAt(Series item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Series withId(Series item, int id) => item.copyWith(id: id);
}
