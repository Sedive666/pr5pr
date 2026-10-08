import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_store/core/api_client.dart';
import 'package:shoe_store/core/api_exceptions.dart';
import 'package:shoe_store/models/queries.dart';
import 'package:shoe_store/models/sneaker.dart';
import 'package:shoe_store/repositories/api_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

({ApiRepository<Sneaker, SneakerQuery> repo, _FakeAdapter adapter}) build(
  ResponseBody Function(RequestOptions options) respond,
) {
  final dio = buildDio();
  final adapter = _FakeAdapter(respond);
  dio.httpClientAdapter = adapter;
  return (
    repo: ApiRepository<Sneaker, SneakerQuery>(
      dio: dio,
      path: 'sneakers',
      decode: Sneaker.fromJson,
      encode: (s) => s.toJson(),
    ),
    adapter: adapter,
  );
}

const _sneaker = Sneaker(
  id: 1,
  name: 'Nike Air Max 90',
  sku: 'CN8490-002',
  year: 2020,
  price: 14990,
  brandId: 1,
  seriesIds: [1],
  categoryIds: [3],
  stockTotal: 12,
  stockAvailable: 7,
);

void main() {
  test('оболочка списка разбирается в PageResult', () async {
    final t = build(
      (_) => _json(200, {
        'items': [
          {
            'id': 1,
            'name': 'Nike Air Max 90',
            'sku': 'CN8490-002',
            'year': 2020,
            'price': 14990,
            'brandId': 1,
            'seriesIds': [1],
            'categoryIds': [3, 5],
            'stockTotal': 12,
            'stockAvailable': 7,
            'brand': {'id': 1, 'name': 'Nike'},
          },
        ],
        'page': 2,
        'size': 10,
        'total': 26,
      }),
    );

    final result = await t.repo.find(const SneakerQuery(page: 2));

    expect(result.items.single.name, 'Nike Air Max 90');
    expect(result.items.single.categoryIds, [3, 5]);
    expect(result.page, 2);
    expect(result.total, 26);
    expect(result.totalPages, 3);
  });

  test('условия отбора уходят в параметры запроса', () async {
    final t = build(
      (_) => _json(200, {'items': [], 'page': 1, 'size': 10, 'total': 0}),
    );

    await t.repo.find(
      const SneakerQuery(
        search: 'air',
        brandId: 1,
        page: 3,
        sortField: 'price',
        sortAscending: false,
      ),
    );

    final params = t.adapter.requests.single.queryParameters;
    expect(params['search'], 'air');
    expect(params['brandId'], '1');
    expect(params['sort'], 'price,desc');
    expect(params['page'], 3);
  });

  test('ответ 422 превращается в ValidationException с полями', () async {
    final t = build(
      (_) => _json(422, {
        'message': 'Ошибка валидации',
        'errors': {'sku': 'Артикул «CN8490-002» уже используется'},
      }),
    );

    await expectLater(
      t.repo.create(_sneaker),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.errors['sku'],
          'ошибка поля sku',
          'Артикул «CN8490-002» уже используется',
        ),
      ),
    );
  });

  test(
    'ответ 409 превращается в ConflictException с текстом сервера',
    () async {
      final t = build(
        (_) => _json(409, {
          'message':
              'Запись нельзя удалить: на неё ссылается связанных записей — 12',
        }),
      );

      await expectLater(
        t.repo.softDelete(1),
        throwsA(
          isA<ConflictException>().having(
            (e) => e.message,
            'сообщение',
            contains('связанных записей — 12'),
          ),
        ),
      );
    },
  );

  test('недоступность сервера превращается в NetworkException', () async {
    final t = build((options) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'сервер не запущен',
      );
    });

    await expectLater(
      t.repo.find(const SneakerQuery()),
      throwsA(isA<NetworkException>()),
    );
    expect(t.adapter.requests.length, 3);
  });

  test(
    'ответ 404 превращается в NotFoundException, findById отдаёт null',
    () async {
      final t = build((_) => _json(404, {'message': 'Объект не найден'}));

      expect(await t.repo.findById(99), isNull);
    },
  );

  test('справочник запрашивается один раз и берётся из кэша', () async {
    final t = build(
      (_) => _json(200, {
        'items': [_sneaker.toJson()],
        'page': 1,
        'size': 100,
        'total': 1,
      }),
    );

    await t.repo.all();
    await t.repo.all();
    expect(t.adapter.requests.length, 1);

    await t.repo.create(_sneaker);
    await t.repo.all();
    expect(t.adapter.requests.length, 3);
  });
}
