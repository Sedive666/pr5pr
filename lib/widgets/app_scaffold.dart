import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const navSections = [
  ('/sneakers', 'Кроссовки'),
  ('/brands', 'Бренды'),
  ('/series', 'Линейки'),
  ('/categories', 'Категории'),
  ('/customers', 'Покупатели'),
  ('/orders', 'Заказы'),
  ('/reviews', 'Отзывы'),
];

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final (path, label) in navSections)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: location.startsWith(path),
                      onSelected: (_) => context.go(path),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
