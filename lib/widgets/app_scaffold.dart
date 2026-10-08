import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/permissions.dart';
import '../state/auth_notifier.dart';

const navSections = [
  ('/my/orders', 'Мои заказы'),
  ('/admin/stats', 'Статистика'),
  ('/admin/users', 'Пользователи'),
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
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final sections = [
      for (final s in navSections)
        if (auth.can(requiredOp(s.$1)!)) s,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.account_circle_outlined, size: 18),
                label: Text('${user.name} · ${user.role.title}'),
              ),
            ),
            IconButton(
              tooltip: 'Выйти',
              icon: const Icon(Icons.logout),
              onPressed: auth.logout,
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final (path, label) in sections)
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
