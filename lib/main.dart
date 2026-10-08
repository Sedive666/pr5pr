import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'models/queries.dart';
import 'repositories/repositories.dart';
import 'router.dart';
import 'state/list_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const ShoeStoreApp());
}

class ShoeStoreApp extends StatelessWidget {
  const ShoeStoreApp({super.key, this.dio, this.router});

  final Dio? dio;
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => dio ?? buildDio()),
        ProxyProvider<Dio, Repositories>(
          update: (_, dio, __) => Repositories(dio),
        ),
        ChangeNotifierProvider<SneakerListNotifier>(
          create: (c) => SneakerListNotifier(
            c.read<Repositories>().sneakers,
            const SneakerQuery(),
          ),
        ),
        ChangeNotifierProvider<SeriesListNotifier>(
          create: (c) => SeriesListNotifier(
            c.read<Repositories>().series,
            const SeriesQuery(),
          ),
        ),
        ChangeNotifierProvider<BrandListNotifier>(
          create: (c) => BrandListNotifier(
            c.read<Repositories>().brands,
            const BrandQuery(),
          ),
        ),
        ChangeNotifierProvider<CategoryListNotifier>(
          create: (c) => CategoryListNotifier(
            c.read<Repositories>().categories,
            const CategoryQuery(),
          ),
        ),
        ChangeNotifierProvider<CustomerListNotifier>(
          create: (c) => CustomerListNotifier(
            c.read<Repositories>().customers,
            const CustomerQuery(),
          ),
        ),
        ChangeNotifierProvider<OrderListNotifier>(
          create: (c) => OrderListNotifier(
            c.read<Repositories>().orders,
            const OrderQuery(),
          ),
        ),
        ChangeNotifierProvider<ReviewListNotifier>(
          create: (c) => ReviewListNotifier(
            c.read<Repositories>().reviews,
            const ReviewQuery(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Магазин кроссовок',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        routerConfig: router ?? appRouter,
      ),
    );
  }
}
