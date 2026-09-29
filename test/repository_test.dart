import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_store/models/page_result.dart';
import 'package:shoe_store/models/series_query.dart';
import 'package:shoe_store/models/sneaker_query.dart';
import 'package:shoe_store/repositories/entity_repository.dart';
import 'package:shoe_store/repositories/series_repository.dart';
import 'package:shoe_store/repositories/sneaker_repository.dart';

void main() {
  late InMemorySneakerRepository repo;

  setUp(() => repo = InMemorySneakerRepository(delay: Duration.zero));

  Future<List<int>> ids(SneakerQuery q) async =>
      (await repo.find(q.copyWith(size: 50))).items.map((s) => s.id).toList();

  test('поиск по названию', () async {
    expect(await ids(const SneakerQuery(search: 'dunk')), hasLength(3));
  });

  test('поиск по артикулу', () async {
    expect(await ids(const SneakerQuery(search: 'dd1391')), [6]);
  });

  test('фильтры комбинируются между собой и с поиском', () async {
    const q = SneakerQuery(brandId: 1, categoryId: 2, yearFrom: 2021);
    expect(await ids(q), [10]);
    expect(await ids(q.copyWith(search: 'retro')), isEmpty);
  });

  test('диапазон года', () async {
    final found = await repo.find(
      const SneakerQuery(yearFrom: 2023, yearTo: 2023, size: 50),
    );
    expect(found.items.every((s) => s.year == 2023), isTrue);
    expect(found.total, 4);
  });

  test('сортировка по цене по убыванию', () async {
    final page = await repo.find(
      const SneakerQuery(sortField: 'price', sortAscending: false),
    );
    expect(page.items.first.name, 'New Balance 991v2');
  });

  test('постраничный вывод', () async {
    final page = await repo.find(const SneakerQuery(page: 3));
    expect(page.total, 26);
    expect(page.totalPages, 3);
    expect(page.items, hasLength(6));
    expect(page.hasNext, isFalse);
  });

  test('логическое удаление, показ удалённых и восстановление', () async {
    await repo.softDelete(1);
    expect(await ids(const SneakerQuery()), isNot(contains(1)));
    expect(await ids(const SneakerQuery(includeDeleted: true)), contains(1));
    await repo.restore(1);
    expect(await ids(const SneakerQuery()), contains(1));
  });

  test('физическое удаление', () async {
    await repo.hardDelete(2);
    expect(await repo.findById(2), isNull);
    expect(
      await ids(const SneakerQuery(includeDeleted: true)),
      isNot(contains(2)),
    );
  });

  test('deleteMany пропускает удалённые и несуществующие записи', () async {
    await repo.softDelete(3);
    expect(await repo.deleteMany([3, 4, 5, 999]), 2);
  });

  test('ошибка источника данных', () async {
    expect(
      repo.find(const SneakerQuery(fail: true)),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('линейки: поиск по стране и фильтр по бренду', () async {
    final series = InMemorySeriesRepository(delay: Duration.zero);
    expect((await series.find(const SeriesQuery(search: 'германия'))).total, 4);
    expect((await series.find(const SeriesQuery(brandId: 3))).total, 4);
  });

  test('пустая страница', () {
    expect(PageResult<int>.empty().totalPages, 1);
  });
}
