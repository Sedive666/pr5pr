import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/entity.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'entity_repository.dart';

class ApiRepository<T extends Entity, Q extends ListQuery<Q>>
    implements EntityRepository<T, Q> {
  ApiRepository({
    required this.dio,
    required this.path,
    required this.decode,
    required this.encode,
  });

  final Dio dio;

  final String path;

  final T Function(Map<String, dynamic> json) decode;
  final Map<String, dynamic> Function(T item) encode;

  List<T>? _options;

  CancelToken? _findToken;

  void _dropCache() => _options = null;

  Map<String, dynamic> _params(Q q) => {
    if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
    ...q.filterParams,
    'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
    'page': q.page,
    'size': q.size,
    if (q.includeDeleted) 'includeDeleted': true,
    if (q.fail) '__fail': 500,
  };

  List<T> _items(dynamic data) =>
      ((data as Map<String, dynamic>)['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(decode)
          .toList();

  @override
  Future<PageResult<T>> find(Q query) => guard(() async {
    _findToken?.cancel('запрос вытеснен более свежим');
    final token = _findToken = CancelToken();

    final response = await dio.get(
      '/$path',
      queryParameters: _params(query),
      cancelToken: token,
    );
    final data = response.data as Map<String, dynamic>;
    return PageResult(
      items: _items(data),
      page: data['page'] as int? ?? 1,
      size: data['size'] as int? ?? query.size,
      total: data['total'] as int? ?? 0,
    );
  });

  @override
  Future<List<T>> all({bool includeDeleted = false}) => guard(() async {
    if (!includeDeleted && _options != null) return _options!;
    final response = await dio.get(
      '/$path',
      queryParameters: {
        'size': 100,
        if (includeDeleted) 'includeDeleted': true,
      },
    );
    final items = _items(response.data);
    if (!includeDeleted) _options = items;
    return items;
  });

  @override
  Future<T?> findById(int id) async {
    try {
      final response = await guard(() => dio.get('/$path/$id'));
      return decode(response.data as Map<String, dynamic>);
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<T> create(T item) => guard(() async {
    final response = await dio.post('/$path', data: encode(item));
    _dropCache();
    return decode(response.data as Map<String, dynamic>);
  });

  @override
  Future<T> update(T item) => guard(() async {
    final response = await dio.put('/$path/${item.id}', data: encode(item));
    _dropCache();
    return decode(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) => guard(() async {
    await dio.delete('/$path/$id');
    _dropCache();
  });

  @override
  Future<void> hardDelete(int id) => guard(() async {
    await dio.delete('/$path/$id', queryParameters: {'hard': true});
    _dropCache();
  });

  @override
  Future<void> restore(int id) => guard(() async {
    await dio.post('/$path/$id/restore');
    _dropCache();
  });

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await dio.post('/$path/bulk-delete', data: {'ids': ids});
    _dropCache();
    return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
  });
}
