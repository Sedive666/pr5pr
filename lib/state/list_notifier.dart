import 'package:flutter/foundation.dart';

import '../models/entity.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import '../models/series.dart';
import '../models/series_query.dart';
import '../models/sneaker.dart';
import '../models/sneaker_query.dart';
import '../repositories/entity_repository.dart';

enum LoadStatus { idle, loading, success, error }

typedef SneakerListNotifier = ListNotifier<Sneaker, SneakerQuery>;
typedef SeriesListNotifier = ListNotifier<Series, SeriesQuery>;

class ListNotifier<T extends Entity, Q extends ListQuery<Q>>
    extends ChangeNotifier {
  ListNotifier(this._repository, this._query);

  final EntityRepository<T, Q> _repository;
  Q _query;
  PageResult<T> _result = PageResult<T>.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  int _ticket = 0;

  Q get query => _query;
  PageResult<T> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    final ticket = ++_ticket;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.find(_query);
      if (ticket != _ticket) return;
      _result = result;
      _status = LoadStatus.success;
    } catch (e) {
      if (ticket != _ticket) return;
      _result = PageResult<T>.empty();
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(Q next) async {
    if (next.sameAs(_query) && _status != LoadStatus.idle) return;
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  void setSelection(Iterable<int> ids, bool value) {
    value ? _selected.addAll(ids) : _selected.removeAll(ids);
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  Future<int> deleteSelected() async {
    final count = await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
    return count;
  }

  Future<T?> findById(int id) => _repository.findById(id);

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }
}
