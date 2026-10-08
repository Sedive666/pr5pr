import 'package:dio/dio.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/queries.dart';
import '../models/review.dart';
import '../models/series.dart';
import '../models/sneaker.dart';
import 'api_repository.dart';

typedef SneakerRepository = ApiRepository<Sneaker, SneakerQuery>;
typedef SeriesRepository = ApiRepository<Series, SeriesQuery>;
typedef BrandRepository = ApiRepository<Brand, BrandQuery>;
typedef CategoryRepository = ApiRepository<Category, CategoryQuery>;
typedef CustomerRepository = ApiRepository<Customer, CustomerQuery>;
typedef OrderRepository = ApiRepository<Order, OrderQuery>;
typedef ReviewRepository = ApiRepository<Review, ReviewQuery>;

class Repositories {
  Repositories(Dio dio)
    : sneakers = SneakerRepository(
        dio: dio,
        path: 'sneakers',
        decode: Sneaker.fromJson,
        encode: (s) => s.toJson(),
      ),
      series = SeriesRepository(
        dio: dio,
        path: 'series',
        decode: Series.fromJson,
        encode: (s) => s.toJson(),
      ),
      brands = BrandRepository(
        dio: dio,
        path: 'brands',
        decode: Brand.fromJson,
        encode: (b) => b.toJson(),
      ),
      categories = CategoryRepository(
        dio: dio,
        path: 'categories',
        decode: Category.fromJson,
        encode: (c) => c.toJson(),
      ),
      customers = CustomerRepository(
        dio: dio,
        path: 'customers',
        decode: Customer.fromJson,
        encode: (c) => c.toJson(),
      ),
      orders = OrderRepository(
        dio: dio,
        path: 'orders',
        decode: Order.fromJson,
        encode: (o) => o.toJson(),
      ),
      reviews = ReviewRepository(
        dio: dio,
        path: 'reviews',
        decode: Review.fromJson,
        encode: (r) => r.toJson(),
      );

  final SneakerRepository sneakers;
  final SeriesRepository series;
  final BrandRepository brands;
  final CategoryRepository categories;
  final CustomerRepository customers;
  final OrderRepository orders;
  final ReviewRepository reviews;
}
