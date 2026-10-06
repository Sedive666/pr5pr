# Практическая работа 3. Формы, валидация и связанные сущности

Магазин кроссовок на Flutter Web. Продолжение ПР2: добавлены формы создания и
редактирования с многоуровневой валидацией, семь сущностей со всеми тремя типами
связей и сохранение данных между перезагрузками страницы.

## Слои

```
screens → widgets → state (ListNotifier, provider) → repositories → models / data
```

| Слой | Содержимое |
| --- | --- |
| `models` | сущности с `copyWith`, `toJson`, `fromJson`; `PageResult<T>`; условия отбора; валидаторы |
| `data` | начальный набор записей |
| `repositories` | `EntityRepository<T, Q>`, общая реализация `InMemoryRepository` с сохранением в localStorage |
| `state` | `ListNotifier<T, Q>` — загрузка, четыре состояния, выделение, сохранение, удаление |
| `widgets` | `EntityTable<T>`, `EntityCardList<T>`, `EntityListView<T, Q>`, `EntityFormScreen` |
| `screens` | экраны сущностей: только описание колонок и полей формы |

Виджеты не обращаются к репозиториям напрямую — только через `ListNotifier`,
полученный из provider. Исключение — `OptionsLoader`, который читает справочники
для выпадающих списков.

## Сущности и связи

| Сущность | Поля | Связи |
| --- | --- | --- |
| Sneaker | id, name, sku\*, year, price, brandId, seriesIds, categoryIds, stockTotal, stockAvailable, deletedAt | многие к одному — Brand; многие ко многим — Series, Category |
| Brand | id, name\*, country, foundedYear, deletedAt | один ко многим — Sneaker, Series |
| Series | id, name, brandId, country, launchYear, deletedAt | многие к одному — Brand; многие ко многим — Sneaker |
| Category | id, name\*, description, deletedAt | многие ко многим — Sneaker |
| Customer | id, firstName, lastName, email\*, phone, city, card, deletedAt | один к одному — LoyaltyCard; один ко многим — Order, Review |
| Order | id, number\*, customerId, sneakerId, size, quantity, price, status, createdAt, deletedAt | многие к одному — Customer, Sneaker |
| Review | id, customerId, sneakerId, rating, text, createdAt, deletedAt | многие к одному — Customer, Sneaker |

Звёздочкой отмечены поля с проверкой уникальности.

Связь один к одному — `LoyaltyCard` (number, level, bonusPoints, issuedAt) —
редактируется вложенной группой полей прямо в форме покупателя.

## Проверки полей

| Поле | Проверки |
| --- | --- |
| Название модели, бренда, линейки, категории | обязательно, длина 2–80 |
| Артикул | обязательно, 4–20 латинских букв, цифр и дефисов, уникален |
| Год выпуска, запуска, основания | обязательно, целое, диапазон |
| Цена, количество пар | обязательно, целое, больше нуля |
| Доступно пар | обязательно, не больше общего количества |
| Бренд, покупатель, модель, размер, оценка | выбор обязателен |
| Линейки, категории | выбран хотя бы один элемент |
| Почта | обязательно, формат, уникальна |
| Телефон | обязательно, формат |
| Номер карты | обязательно, 8–16 цифр |
| Бонусные баллы | обязательно, неотрицательное целое |
| Текст отзыва | обязательно, длина 10–500 |

Валидаторы собраны в `lib/models/validators.dart` и переиспользуются всеми
формами через `combine([...])`.

## Сохранение данных

`InMemoryRepository` пишет список в `shared_preferences` (на web — localStorage)
после каждого изменения. Ключ содержит версию формата: `sneakers_v1`. При смене
версии старые ключи удаляются, а пользователь видит сообщение. Повреждённые
данные не роняют приложение: разбор обёрнут в `try/catch`, при ошибке
восстанавливается начальный набор.

## Целостность связей

Запись нельзя удалить, пока на неё ссылаются другие: репозитории связаны через
`dependsOn`, и при попытке удаления выводится число связанных записей. Например,
бренд Nike не удаляется, пока существуют его модели и линейки.

## Адреса

```
/sneakers                     список с поиском, фильтрами, сортировкой, страницами
/sneakers/new                 создание
/sneakers/5                   карточка
/sneakers/5/edit              изменение
```

Те же пять адресов есть у `/brands`, `/series`, `/categories`, `/customers`,
`/orders`, `/reviews`. Условия отбора хранятся в адресе:
`/sneakers?search=air&brandId=1&seriesId=1&sort=price,desc&page=2`.
Адрес `/sneakers?fail=1` имитирует ошибку источника данных.

## Ошибка в deleteMany

В методических указаниях в методе `deleteMany` намеренно оставлена ошибка:

```dart
final i = _books.indexWhere((b) => b.id == id && !b[i].isDeleted);
```

Внутри лямбды используется переменная `i`, которая объявляется этой же строкой, —
обращаться к переменной в её собственном инициализаторе нельзя. Кроме того, `b` —
это одна запись, а не список, и индексировать её невозможно. Проверять нужно сам
элемент, поэтому условие исправлено на `!b.isDeleted`.

## Запуск

```bash
flutter pub get
flutter run -d chrome --web-port=5557
flutter analyze
flutter test
```

Сборка `flutter build web` требует пути без кириллицы: `subst P: "<путь>"`.
