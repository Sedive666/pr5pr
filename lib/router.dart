import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/series_query.dart';
import 'models/sneaker_query.dart';
import 'screens/series_screens.dart';
import 'screens/sneaker_screens.dart';
import 'widgets/entity_list_view.dart';

int _id(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;

GoRouter createRouter({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/sneakers'),
    GoRoute(
      path: '/sneakers',
      builder: (context, state) => SneakerListScreen(
        query: SneakerQuery.fromParams(state.uri.queryParameters),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => SneakerDetailScreen(id: _id(state)),
        ),
      ],
    ),
    GoRoute(
      path: '/series',
      builder: (context, state) => SeriesListScreen(
        query: SeriesQuery.fromParams(state.uri.queryParameters),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => SeriesDetailScreen(id: _id(state)),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => AppScaffold(
    title: 'Страница не найдена',
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('404', style: Theme.of(context).textTheme.displayLarge),
          Text(state.uri.toString()),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/sneakers'),
            child: const Text('К каталогу'),
          ),
        ],
      ),
    ),
  ),
);

final appRouter = createRouter();
