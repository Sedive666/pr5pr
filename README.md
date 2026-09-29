# Практическая работа 2. Магазин кроссовок: списки, поиск, фильтрация, пагинация

Каталог кроссовок (Nike, Adidas, New Balance) и линеек на Flutter Web. Данные хранятся в памяти.

| Методичка | Проект |
| --- | --- |
| Book | Sneaker — модель, артикул, год, цена, бренд, линейка, категория, наличие |
| Author | Series — линейка, бренд, страна, год запуска |
| Publisher / Genre | Brand / Category (справочники в `models/catalog.dart`) |

## Слои

```
screens  →  widgets  →  state (ListNotifier, provider)  →  repositories  →  models / data
```

- `models` — сущности с `copyWith`, `PageResult<T>`, условия отбора `SneakerQuery` / `SeriesQuery`
- `repositories` — интерфейс `EntityRepository<T, Q>`, общая реализация в памяти `InMemoryRepository`
- `state` — `ListNotifier<T, Q>` (ChangeNotifier): загрузка, 4 состояния, выделение, удаление
- `widgets` — `EntityTable<T>`, `EntityCardList<T>`, `EntityListView<T, Q>`, поиск с задержкой, пагинация
- `screens` — экраны кроссовок и линеек задают только колонки и фильтры

Виджеты не обращаются к репозиторию напрямую — только через `ListNotifier`.

## Адреса

```
/sneakers?search=air&brandId=1&categoryId=3&yearFrom=2019&yearTo=2022&sort=price,desc&page=2&size=25&deleted=1
/sneakers/5
/series?search=германия&brandId=2&sort=year,desc
/sneakers?fail=1        имитация ошибки загрузки
```

## Ошибка в deleteMany

```dart
final i = _books.indexWhere((b) => b.id == id && !b[i].isDeleted);
```

Внутри лямбды используется переменная `i`, которая объявляется этой же строкой, — к ней нельзя обращаться в собственном инициализаторе. Кроме того, `b` — это одна книга, а не список, и индексировать её нельзя. Проверять нужно сам элемент: `!b.isDeleted`. Исправленный вариант — `InMemoryRepository.deleteMany`.

## Запуск

```bash
flutter pub get
flutter run -d chrome --web-port=5555
flutter analyze
flutter test
```
