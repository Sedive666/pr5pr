import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/entity.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'entity_repository.dart';

typedef ReferenceCheck = Future<int> Function(int id);

abstract class InMemoryRepository<T extends Entity, Q extends ListQuery<Q>>
    implements EntityRepository<T, Q> {
  InMemoryRepository(
    List<T> seed, {
    this.delay = const Duration(milliseconds: 250),
    this.prefs,
  }) : _seed = seed {
    _restore();
  }

  final List<T> _seed;
  final Duration delay;
  final SharedPreferences? prefs;
  final List<ReferenceCheck> _references = [];

  List<T> _rows = [];
  int _nextId = 1;
  String? storageWarning;

  String get storageKey;
  int get storageVersion => 1;

  bool matches(T item, Q query);
  int compareBy(String field, T a, T b);
  T withDeletedAt(T item, DateTime? at);
  T withId(T item, int id);
  Map<String, dynamic> encode(T item);
  T decode(Map<String, dynamic> json);

  String? uniqueValue(T item) => null;
  String get uniqueLabel => '';
  String get uniqueField => '';

  void dependsOn(ReferenceCheck check) => _references.add(check);

  String get _key => '${storageKey}_v$storageVersion';

  void _restore() {
    final raw = prefs?.getString(_key);
    if (raw == null) {
      _reset();
      _detectOldVersions();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _rows = list
          .map((e) => decode((e as Map).map((k, v) => MapEntry('$k', v))))
          .where((e) => e.id > 0)
          .toList();
      _nextId = _rows.fold<int>(0, (m, e) => e.id > m ? e.id : m) + 1;
      if (_rows.isEmpty) _reset();
    } catch (_) {
      storageWarning =
          'Сохранённые данные повреждены, восстановлен начальный набор';
      _reset();
    }
  }

  void _detectOldVersions() {
    if (prefs == null) return;
    for (var v = storageVersion - 1; v >= 1; v--) {
      if (prefs!.containsKey('${storageKey}_v$v')) {
        prefs!.remove('${storageKey}_v$v');
        storageWarning =
            'Формат данных обновлён, список восстановлен из начального набора';
      }
    }
  }

  void _reset() {
    _rows = [..._seed];
    _nextId = _seed.fold<int>(0, (m, e) => e.id > m ? e.id : m) + 1;
    _persist();
  }

  void _persist() {
    prefs?.setString(_key, jsonEncode(_rows.map(encode).toList()));
  }

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

  @override
  Future<List<T>> all({bool includeDeleted = false}) async =>
      _rows.where((e) => includeDeleted || !e.isDeleted).toList();

  int _indexOf(int id) {
    final i = _rows.indexWhere((e) => e.id == id);
    if (i == -1) throw RepositoryException('Запись $id не найдена');
    return i;
  }

  void _checkUnique(T item) {
    final value = uniqueValue(item)?.trim().toLowerCase();
    if (value == null || value.isEmpty) return;
    final clash = _rows.any(
      (e) => e.id != item.id && uniqueValue(e)?.trim().toLowerCase() == value,
    );
    if (clash) {
      throw FieldException(
        uniqueField,
        '$uniqueLabel «${uniqueValue(item)}» уже используется',
      );
    }
  }

  Future<void> _checkReferences(int id) async {
    for (final check in _references) {
      final count = await check(id);
      if (count > 0) {
        throw RepositoryException(
          'Запись нельзя удалить: на неё ссылается связанных записей — $count',
        );
      }
    }
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
    _checkUnique(withId(item, 0));
    final created = withId(item, _nextId++);
    _rows.add(created);
    _persist();
    return created;
  }

  @override
  Future<T> update(T item) async {
    _checkUnique(item);
    _rows[_indexOf(item.id)] = item;
    _persist();
    return item;
  }

  @override
  Future<void> softDelete(int id) async {
    await _checkReferences(id);
    final i = _indexOf(id);
    _rows[i] = withDeletedAt(_rows[i], DateTime.now());
    _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    await _checkReferences(id);
    _rows.removeWhere((e) => e.id == id);
    _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _indexOf(id);
    _rows[i] = withDeletedAt(_rows[i], null);
    _persist();
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
    _persist();
    return count;
  }

  @override
  Future<int> countWhere(bool Function(T item) test) async =>
      _rows.where((e) => !e.isDeleted && test(e)).length;
}
