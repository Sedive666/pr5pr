import '../models/entity.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';

class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FieldException implements Exception {
  const FieldException(this.field, this.message);

  final String field;
  final String message;

  @override
  String toString() => message;
}

abstract interface class EntityRepository<
  T extends Entity,
  Q extends ListQuery<Q>
> {
  Future<PageResult<T>> find(Q query);
  Future<List<T>> all({bool includeDeleted});
  Future<T?> findById(int id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
