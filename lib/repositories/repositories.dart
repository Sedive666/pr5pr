import '../data/seed.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/queries.dart';
import '../models/review.dart';
import '../models/series.dart';
import '../models/sneaker.dart';
import 'in_memory_repository.dart';

class SneakerRepository extends InMemoryRepository<Sneaker, SneakerQuery> {
  SneakerRepository({List<Sneaker>? seed, super.delay, super.prefs})
    : super(seed ?? seedSneakers);

  @override
  String get storageKey => 'sneakers';

  @override
  String get uniqueField => 'sku';

  @override
  String get uniqueLabel => 'Артикул';

  @override
  String? uniqueValue(Sneaker item) => item.sku;

  @override
  bool matches(Sneaker s, SneakerQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty ||
            s.name.toLowerCase().contains(needle) ||
            s.sku.toLowerCase().contains(needle)) &&
        (q.categoryId == null || s.categoryIds.contains(q.categoryId)) &&
        (q.seriesId == null || s.seriesIds.contains(q.seriesId)) &&
        (q.brandId == null || s.brandId == q.brandId) &&
        (q.yearFrom == null || s.year >= q.yearFrom!) &&
        (q.yearTo == null || s.year <= q.yearTo!);
  }

  @override
  int compareBy(String field, Sneaker a, Sneaker b) => switch (field) {
    'year' => a.year.compareTo(b.year),
    'price' => a.price.compareTo(b.price),
    'stock' => a.stockAvailable.compareTo(b.stockAvailable),
    _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  };

  @override
  Sneaker withDeletedAt(Sneaker item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Sneaker withId(Sneaker item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Sneaker item) => item.toJson();

  @override
  Sneaker decode(Map<String, dynamic> json) => Sneaker.fromJson(json);
}

class SeriesRepository extends InMemoryRepository<Series, SeriesQuery> {
  SeriesRepository({List<Series>? seed, super.delay, super.prefs})
    : super(seed ?? seedSeries);

  @override
  String get storageKey => 'series';

  @override
  bool matches(Series s, SeriesQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty ||
            s.name.toLowerCase().contains(needle) ||
            s.country.toLowerCase().contains(needle)) &&
        (q.brandId == null || s.brandId == q.brandId);
  }

  @override
  int compareBy(String field, Series a, Series b) => switch (field) {
    'year' => a.launchYear.compareTo(b.launchYear),
    'country' => a.country.compareTo(b.country),
    _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  };

  @override
  Series withDeletedAt(Series item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Series withId(Series item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Series item) => item.toJson();

  @override
  Series decode(Map<String, dynamic> json) => Series.fromJson(json);
}

class BrandRepository extends InMemoryRepository<Brand, BrandQuery> {
  BrandRepository({List<Brand>? seed, super.delay, super.prefs})
    : super(seed ?? seedBrands);

  @override
  String get storageKey => 'brands';

  @override
  String get uniqueField => 'name';

  @override
  String get uniqueLabel => 'Бренд';

  @override
  String? uniqueValue(Brand item) => item.name;

  @override
  bool matches(Brand b, BrandQuery q) {
    final needle = q.search.trim().toLowerCase();
    return needle.isEmpty ||
        b.name.toLowerCase().contains(needle) ||
        b.country.toLowerCase().contains(needle);
  }

  @override
  int compareBy(String field, Brand a, Brand b) => switch (field) {
    'country' => a.country.compareTo(b.country),
    'year' => a.foundedYear.compareTo(b.foundedYear),
    _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  };

  @override
  Brand withDeletedAt(Brand item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Brand withId(Brand item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Brand item) => item.toJson();

  @override
  Brand decode(Map<String, dynamic> json) => Brand.fromJson(json);
}

class CategoryRepository extends InMemoryRepository<Category, CategoryQuery> {
  CategoryRepository({List<Category>? seed, super.delay, super.prefs})
    : super(seed ?? seedCategories);

  @override
  String get storageKey => 'categories';

  @override
  String get uniqueField => 'name';

  @override
  String get uniqueLabel => 'Категория';

  @override
  String? uniqueValue(Category item) => item.name;

  @override
  bool matches(Category c, CategoryQuery q) {
    final needle = q.search.trim().toLowerCase();
    return needle.isEmpty ||
        c.name.toLowerCase().contains(needle) ||
        c.description.toLowerCase().contains(needle);
  }

  @override
  int compareBy(String field, Category a, Category b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  @override
  Category withDeletedAt(Category item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Category withId(Category item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Category item) => item.toJson();

  @override
  Category decode(Map<String, dynamic> json) => Category.fromJson(json);
}

class CustomerRepository extends InMemoryRepository<Customer, CustomerQuery> {
  CustomerRepository({List<Customer>? seed, super.delay, super.prefs})
    : super(seed ?? seedCustomers);

  @override
  String get storageKey => 'customers';

  @override
  String get uniqueField => 'email';

  @override
  String get uniqueLabel => 'Почта';

  @override
  String? uniqueValue(Customer item) => item.email;

  @override
  bool matches(Customer c, CustomerQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty ||
            c.fullName.toLowerCase().contains(needle) ||
            c.email.toLowerCase().contains(needle) ||
            c.phone.contains(needle)) &&
        (q.city == null || c.city == q.city);
  }

  @override
  int compareBy(String field, Customer a, Customer b) => switch (field) {
    'city' => a.city.compareTo(b.city),
    'bonus' => (a.card?.bonusPoints ?? 0).compareTo(b.card?.bonusPoints ?? 0),
    _ => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
  };

  @override
  Customer withDeletedAt(Customer item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Customer withId(Customer item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Customer item) => item.toJson();

  @override
  Customer decode(Map<String, dynamic> json) => Customer.fromJson(json);
}

class OrderRepository extends InMemoryRepository<Order, OrderQuery> {
  OrderRepository({List<Order>? seed, super.delay, super.prefs})
    : super(seed ?? seedOrders);

  @override
  String get storageKey => 'orders';

  @override
  String get uniqueField => 'number';

  @override
  String get uniqueLabel => 'Номер заказа';

  @override
  String? uniqueValue(Order item) => item.number;

  @override
  bool matches(Order o, OrderQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty || o.number.toLowerCase().contains(needle)) &&
        (q.status == null || o.status == q.status) &&
        (q.customerId == null || o.customerId == q.customerId);
  }

  @override
  int compareBy(String field, Order a, Order b) => switch (field) {
    'date' => a.createdAt.compareTo(b.createdAt),
    'total' => a.total.compareTo(b.total),
    _ => a.number.compareTo(b.number),
  };

  @override
  Order withDeletedAt(Order item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Order withId(Order item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Order item) => item.toJson();

  @override
  Order decode(Map<String, dynamic> json) => Order.fromJson(json);
}

class ReviewRepository extends InMemoryRepository<Review, ReviewQuery> {
  ReviewRepository({List<Review>? seed, super.delay, super.prefs})
    : super(seed ?? seedReviews);

  @override
  String get storageKey => 'reviews';

  @override
  bool matches(Review r, ReviewQuery q) {
    final needle = q.search.trim().toLowerCase();
    return (needle.isEmpty || r.text.toLowerCase().contains(needle)) &&
        (q.rating == null || r.rating == q.rating) &&
        (q.sneakerId == null || r.sneakerId == q.sneakerId);
  }

  @override
  int compareBy(String field, Review a, Review b) => switch (field) {
    'rating' => a.rating.compareTo(b.rating),
    _ => a.createdAt.compareTo(b.createdAt),
  };

  @override
  Review withDeletedAt(Review item, DateTime? at) => at == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: at);

  @override
  Review withId(Review item, int id) => item.copyWith(id: id);

  @override
  Map<String, dynamic> encode(Review item) => item.toJson();

  @override
  Review decode(Map<String, dynamic> json) => Review.fromJson(json);
}

class Repositories {
  Repositories({
    required this.sneakers,
    required this.series,
    required this.brands,
    required this.categories,
    required this.customers,
    required this.orders,
    required this.reviews,
  }) {
    brands.dependsOn((id) => sneakers.countWhere((s) => s.brandId == id));
    brands.dependsOn((id) => series.countWhere((s) => s.brandId == id));
    series.dependsOn((id) => sneakers.countWhere((s) => s.seriesIds.contains(id)));
    categories.dependsOn(
      (id) => sneakers.countWhere((s) => s.categoryIds.contains(id)),
    );
    customers.dependsOn((id) => orders.countWhere((o) => o.customerId == id));
    customers.dependsOn((id) => reviews.countWhere((r) => r.customerId == id));
    sneakers.dependsOn((id) => orders.countWhere((o) => o.sneakerId == id));
    sneakers.dependsOn((id) => reviews.countWhere((r) => r.sneakerId == id));
  }

  final SneakerRepository sneakers;
  final SeriesRepository series;
  final BrandRepository brands;
  final CategoryRepository categories;
  final CustomerRepository customers;
  final OrderRepository orders;
  final ReviewRepository reviews;

  String? get storageWarning => [
    sneakers.storageWarning,
    series.storageWarning,
    brands.storageWarning,
    categories.storageWarning,
    customers.storageWarning,
    orders.storageWarning,
    reviews.storageWarning,
  ].firstWhere((e) => e != null, orElse: () => null);
}
