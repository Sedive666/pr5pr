import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_store/main.dart';
import 'package:shoe_store/models/sneaker_query.dart';
import 'package:shoe_store/router.dart';

void main() {
  test('адрес разбирается в условия отбора', () {
    final q = SneakerQuery.fromParams({
      'search': 'air',
      'brandId': '1',
      'sort': 'price,desc',
      'page': '2',
      'size': '25',
    });
    expect(q.search, 'air');
    expect(q.brandId, 1);
    expect(q.sortField, 'price');
    expect(q.sortAscending, isFalse);
    expect(q.page, 2);
    expect(q.size, 25);
  });

  test('условия отбора превращаются обратно в тот же адрес', () {
    final params = {
      'search': 'air',
      'categoryId': '3',
      'sort': 'year,desc',
      'page': '3',
    };
    expect(SneakerQuery.fromParams(params).toParams(), params);
  });

  test('некорректные параметры заменяются значениями по умолчанию', () {
    final q = SneakerQuery.fromParams({
      'sort': 'hack,desc',
      'page': '-5',
      'size': '7',
    });
    expect(q.sortField, 'name');
    expect(q.sortAscending, isTrue);
    expect(q.page, 1);
    expect(q.size, 10);
  });

  test(
    'смена условий возвращает на первую страницу, null сбрасывает фильтр',
    () {
      const q = SneakerQuery(page: 5, brandId: 2);
      final next = q.copyWith(brandId: null);
      expect(next.page, 1);
      expect(next.brandId, isNull);
      expect(q.copyWith(search: 'x').brandId, 2);
    },
  );

  Future<void> open(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ShoeStoreApp(router: createRouter(initialLocation: location)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('список восстанавливается из адреса', (tester) async {
    await open(tester, '/sneakers?search=ultraboost');
    expect(find.text('Adidas Ultraboost 22'), findsOneWidget);
    expect(find.text('Всего записей: 3'), findsOneWidget);
  });

  testWidgets('пустой результат', (tester) async {
    await open(tester, '/sneakers?search=zzz');
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('состояние ошибки отличается от пустого', (tester) async {
    await open(tester, '/sneakers?fail=1');
    expect(find.text('Ошибка загрузки'), findsOneWidget);
    expect(find.text('Ничего не найдено'), findsNothing);
  });

  testWidgets('узкое окно показывает карточки', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ShoeStoreApp(router: createRouter(initialLocation: '/series')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);
    expect(find.byType(DataTable), findsNothing);
  });
}
