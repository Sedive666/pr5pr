import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/series_query.dart';
import 'models/sneaker_query.dart';
import 'repositories/series_repository.dart';
import 'repositories/sneaker_repository.dart';
import 'router.dart';
import 'state/list_notifier.dart';

void main() {
  usePathUrlStrategy();
  runApp(const ShoeStoreApp());
}

class ShoeStoreApp extends StatelessWidget {
  const ShoeStoreApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SneakerRepository>(create: (_) => InMemorySneakerRepository()),
        Provider<SeriesRepository>(create: (_) => InMemorySeriesRepository()),
        ChangeNotifierProvider<SneakerListNotifier>(
          create: (c) => SneakerListNotifier(
            c.read<SneakerRepository>(),
            const SneakerQuery(),
          ),
        ),
        ChangeNotifierProvider<SeriesListNotifier>(
          create: (c) => SeriesListNotifier(
            c.read<SeriesRepository>(),
            const SeriesQuery(),
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
