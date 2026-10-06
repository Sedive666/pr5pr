import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_store/models/brand.dart';
import 'package:shoe_store/models/queries.dart';
import 'package:shoe_store/models/sneaker.dart';
import 'package:shoe_store/repositories/entity_repository.dart';
import 'package:shoe_store/repositories/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SneakerRepository repo;

  setUp(() => repo = SneakerRepository(delay: Duration.zero));

  Future<List<int>> ids(SneakerQuery q) async =>
      (await repo.find(q.copyWith(size: 50))).items.map((s) => s.id).toList();

  test('поиск по названию и артикулу', () async {
    expect(await ids(const SneakerQuery(search: 'dunk')), hasLength(3));
    expect(await ids(const SneakerQuery(search: 'dd1391')), [6]);
  });

  test('фильтры комбинируются между собой и с поиском', () async {
    const q = SneakerQuery(brandId: 1, categoryId: 2, yearFrom: 2021);
    expect(await ids(q), [10]);
    expect(await ids(q.copyWith(search: 'retro')), isEmpty);
  });

  test('фильтр по линейке работает по связи многие ко многим', () async {
    expect(await ids(const SneakerQuery(seriesId: 13)), [6, 7]);
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

  test('повтор артикула не сохраняется', () async {
    final clash = Sneaker(
      id: 0,
      name: 'Копия',
      sku: 'CN8490-002',
      year: 2024,
      price: 10000,
      brandId: 1,
      seriesIds: const [1],
      categoryIds: const [3],
      stockTotal: 1,
      stockAvailable: 1,
    );
    expect(
      repo.create(clash),
      throwsA(
        isA<FieldException>().having((e) => e.field, 'поле', 'sku'),
      ),
    );
    expect(repo.create(clash.copyWith(sku: 'NEW-0001')), completes);
  });

  test('повтор почты покупателя не сохраняется', () async {
    final customers = CustomerRepository(delay: Duration.zero);
    final first = (await customers.all()).first;
    expect(
      customers.update(first.copyWith(id: 3, email: first.email)),
      throwsA(
        isA<FieldException>().having((e) => e.field, 'поле', 'email'),
      ),
    );
  });

  test('бренд со связанными моделями не удаляется', () async {
    final repos = _repositories();
    expect(
      repos.brands.softDelete(1),
      throwsA(isA<RepositoryException>()),
    );
    final free = await repos.brands.create(
      const Brand(id: 0, name: 'Puma', country: 'Германия', foundedYear: 1948),
    );
    expect(repos.brands.hardDelete(free.id), completes);
  });

  test('данные сохраняются между запусками', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final first = SneakerRepository(delay: Duration.zero, prefs: prefs);
    await first.softDelete(1);
    await first.update(
      (await first.findById(2))!.copyWith(name: 'Переименованная модель'),
    );

    final second = SneakerRepository(delay: Duration.zero, prefs: prefs);
    expect((await second.findById(1))!.isDeleted, isTrue);
    expect((await second.findById(2))!.name, 'Переименованная модель');
  });

  test('повреждённое хранилище не роняет приложение', () async {
    SharedPreferences.setMockInitialValues({'sneakers_v1': 'не json'});
    final prefs = await SharedPreferences.getInstance();
    final repo = SneakerRepository(delay: Duration.zero, prefs: prefs);
    expect((await repo.all()), hasLength(26));
    expect(repo.storageWarning, isNotNull);
  });
}

Repositories _repositories() => Repositories(
  sneakers: SneakerRepository(delay: Duration.zero),
  series: SeriesRepository(delay: Duration.zero),
  brands: BrandRepository(delay: Duration.zero),
  categories: CategoryRepository(delay: Duration.zero),
  customers: CustomerRepository(delay: Duration.zero),
  orders: OrderRepository(delay: Duration.zero),
  reviews: ReviewRepository(delay: Duration.zero),
);
