import '../models/entity.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'entity_repository.dart';

abstract class InMemoryRepository<T extends Entity, Q extends ListQuery<Q>>
    implements EntityRepository<T, Q> {
  InMemoryRepository(
    List<T> seed, {
    this.delay = const Duration(milliseconds: 250),
  }) : _rows = [...seed],
       _nextId = seed.fold<int>(0, (m, e) => e.id > m ? e.id : m) + 1;

  final List<T> _rows;
  final Duration delay;
  int _nextId;

  bool matches(T item, Q query);
  int compareBy(String field, T a, T b);
  T withDeletedAt(T item, DateTime? at);
  T withId(T item, int id);

  @override
  Future<PageResult<T>> find(Q q) async {
    await Future.delayed(delay);
    if (q.fail) throw const RepositoryException('сервер не отвечает');

    final rows =
        _rows
            .where((e) => (q.includeDeleted || !e.isDeleted) && matches(e, q))
            .toList()
          ..sort((a, b) {
            final r = compareBy(q.sortField, a, b);
            return q.sortAscending ? r : -r;
          });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <T>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  int _indexOf(int id) {
    final i = _rows.indexWhere((e) => e.id == id);
    if (i == -1) throw RepositoryException('Запись $id не найдена');
    return i;
  }

  @override
  Future<T?> findById(int id) async {
    for (final e in _rows) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<T> create(T item) async {
    final created = withId(item, _nextId++);
    _rows.add(created);
    return created;
  }

  @override
  Future<T> update(T item) async {
    _rows[_indexOf(item.id)] = item;
    return item;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _indexOf(id);
    _rows[i] = withDeletedAt(_rows[i], DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _rows.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _indexOf(id);
    _rows[i] = withDeletedAt(_rows[i], null);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    final now = DateTime.now();
    for (final id in ids) {
      final i = _rows.indexWhere((e) => e.id == id && !e.isDeleted);
      if (i != -1) {
        _rows[i] = withDeletedAt(_rows[i], now);
        count++;
      }
    }
    return count;
  }
}
