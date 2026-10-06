import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/queries.dart';
import 'repositories/repositories.dart';
import 'router.dart';
import 'state/list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  runApp(ShoeStoreApp(repositories: buildRepositories(prefs)));
}

Repositories buildRepositories(
  SharedPreferences? prefs, {
  Duration delay = const Duration(milliseconds: 250),
}) => Repositories(
  sneakers: SneakerRepository(prefs: prefs, delay: delay),
  series: SeriesRepository(prefs: prefs, delay: delay),
  brands: BrandRepository(prefs: prefs, delay: delay),
  categories: CategoryRepository(prefs: prefs, delay: delay),
  customers: CustomerRepository(prefs: prefs, delay: delay),
  orders: OrderRepository(prefs: prefs, delay: delay),
  reviews: ReviewRepository(prefs: prefs, delay: delay),
);

class ShoeStoreApp extends StatelessWidget {
  const ShoeStoreApp({super.key, required this.repositories, this.router});

  final Repositories repositories;
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Repositories>.value(value: repositories),
        ChangeNotifierProvider<SneakerListNotifier>(
          create: (_) =>
              SneakerListNotifier(repositories.sneakers, const SneakerQuery()),
        ),
        ChangeNotifierProvider<SeriesListNotifier>(
          create: (_) =>
              SeriesListNotifier(repositories.series, const SeriesQuery()),
        ),
        ChangeNotifierProvider<BrandListNotifier>(
          create: (_) =>
              BrandListNotifier(repositories.brands, const BrandQuery()),
        ),
        ChangeNotifierProvider<CategoryListNotifier>(
          create: (_) => CategoryListNotifier(
            repositories.categories,
            const CategoryQuery(),
          ),
        ),
        ChangeNotifierProvider<CustomerListNotifier>(
          create: (_) => CustomerListNotifier(
            repositories.customers,
            const CustomerQuery(),
          ),
        ),
        ChangeNotifierProvider<OrderListNotifier>(
          create: (_) =>
              OrderListNotifier(repositories.orders, const OrderQuery()),
        ),
        ChangeNotifierProvider<ReviewListNotifier>(
          create: (_) =>
              ReviewListNotifier(repositories.reviews, const ReviewQuery()),
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
        builder: (context, child) =>
            _StorageNotice(repositories: repositories, child: child),
      ),
    );
  }
}

class _StorageNotice extends StatefulWidget {
  const _StorageNotice({required this.repositories, required this.child});

  final Repositories repositories;
  final Widget? child;

  @override
  State<_StorageNotice> createState() => _StorageNoticeState();
}

class _StorageNoticeState extends State<_StorageNotice> {
  @override
  void initState() {
    super.initState();
    final warning = widget.repositories.storageWarning;
    if (warning != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(warning)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}
