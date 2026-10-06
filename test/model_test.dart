import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_store/models/customer.dart';
import 'package:shoe_store/models/order.dart';
import 'package:shoe_store/models/queries.dart';
import 'package:shoe_store/models/review.dart';
import 'package:shoe_store/models/sneaker.dart';
import 'package:shoe_store/models/validators.dart';

void main() {
  group('разбор данных', () {
    test('полный объект превращается в JSON и обратно', () {
      const source = Sneaker(
        id: 7,
        name: 'Nike Dunk',
        sku: 'BQ6817-100',
        year: 2019,
        price: 10990,
        brandId: 1,
        seriesIds: [3, 13],
        categoryIds: [4],
        stockTotal: 9,
        stockAvailable: 5,
      );
      final restored = Sneaker.fromJson(source.toJson());
      expect(restored.name, source.name);
      expect(restored.seriesIds, source.seriesIds);
      expect(restored.deletedAt, isNull);
    });

    test('отсутствующие поля заменяются значениями по умолчанию', () {
      final s = Sneaker.fromJson({'id': 5});
      expect(s.name, '');
      expect(s.price, 0);
      expect(s.seriesIds, isEmpty);
    });

    test('null и чужие типы не роняют разбор', () {
      final s = Sneaker.fromJson({
        'id': '12',
        'name': null,
        'year': '2020',
        'price': 15990.0,
        'seriesIds': null,
        'categoryIds': ['3', 4, null],
        'deletedAt': 'не дата',
      });
      expect(s.id, 12);
      expect(s.year, 2020);
      expect(s.price, 15990);
      expect(s.categoryIds, [3, 4]);
      expect(s.deletedAt, isNull);
    });

    test('вложенная карта лояльности', () {
      final c = Customer.fromJson({
        'id': 1,
        'lastName': 'Петров',
        'card': {'number': '10000001', 'level': 'Золотая', 'bonusPoints': 100},
      });
      expect(c.card!.number, '10000001');
      expect(c.card!.level, 'Золотая');
      expect(Customer.fromJson({'id': 2}).card, isNull);
    });

    test('неизвестные значения перечислений заменяются допустимыми', () {
      expect(Order.fromJson({'id': 1, 'status': 'взломан'}).status, 'Новый');
      expect(Review.fromJson({'id': 1, 'rating': 99}).rating, 5);
      expect(
        Customer.fromJson({
          'id': 1,
          'card': {'level': 'Алмазная'},
        }).card!.level,
        'Серебряная',
      );
    });

    test('copyWith сбрасывает дату удаления только по флагу', () {
      final deleted = const Sneaker(
        id: 1,
        name: 'x',
        sku: 'x',
        year: 2020,
        price: 1,
        brandId: 1,
        stockTotal: 1,
        stockAvailable: 1,
      ).copyWith(deletedAt: DateTime(2025));
      expect(deleted.copyWith(name: 'y').deletedAt, isNotNull);
      expect(deleted.copyWith(clearDeletedAt: true).deletedAt, isNull);
    });
  });

  group('валидаторы', () {
    test('обязательность и длина', () {
      expect(notEmpty()(''), isNotNull);
      expect(notEmpty()('  '), isNotNull);
      expect(notEmpty()('текст'), isNull);
      expect(length(3, 5)('ab'), isNotNull);
      expect(length(3, 5)('abcdef'), isNotNull);
      expect(length(3, 5)('abcd'), isNull);
    });

    test('диапазон чисел', () {
      expect(intRange(1, 10)('0'), isNotNull);
      expect(intRange(1, 10)('11'), isNotNull);
      expect(intRange(1, 10)('абв'), isNotNull);
      expect(intRange(1, 10)('5'), isNull);
    });

    test('почта, телефон, артикул и номер карты', () {
      expect(email()('без-собаки'), isNotNull);
      expect(email()('user@mail.ru'), isNull);
      expect(phone()('123'), isNotNull);
      expect(phone()('+7 916 123-45-67'), isNull);
      expect(sku()('ab'), isNotNull);
      expect(sku()('CN8490-002'), isNull);
      expect(cardNumber()('123'), isNotNull);
      expect(cardNumber()('10000001'), isNull);
    });

    test('combine возвращает первую ошибку', () {
      final v = combine([notEmpty(), email()]);
      expect(v(''), 'Поле обязательно для заполнения');
      expect(v('мусор'), 'Неверный формат почты');
      expect(v('a@b.ru'), isNull);
    });
  });

  group('условия отбора', () {
    test('адрес разбирается и собирается обратно', () {
      final params = {
        'search': 'air',
        'brandId': '1',
        'sort': 'price,desc',
        'page': '2',
        'size': '25',
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
      expect(q.page, 1);
      expect(q.size, 10);
    });

    test('смена условий возвращает на первую страницу', () {
      const q = SneakerQuery(page: 5, brandId: 2);
      expect(q.copyWith(search: 'x').page, 1);
      expect(q.copyWith(brandId: null).brandId, isNull);
      expect(q.copyWith(search: 'x').brandId, 2);
    });
  });
}
