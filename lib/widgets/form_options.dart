import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/series.dart';
import '../models/sneaker.dart';
import '../core/api_exceptions.dart';
import '../core/permissions.dart';
import '../repositories/repositories.dart';
import '../state/auth_notifier.dart';
import 'app_scaffold.dart';

class CatalogOptions {
  const CatalogOptions({
    required this.brands,
    required this.series,
    required this.categories,
    required this.customers,
    required this.sneakers,
  });

  final List<Brand> brands;
  final List<Series> series;
  final List<Category> categories;
  final List<Customer> customers;
  final List<Sneaker> sneakers;
}

class OptionsLoader extends StatefulWidget {
  const OptionsLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, CatalogOptions options) builder;

  @override
  State<OptionsLoader> createState() => _OptionsLoaderState();
}

class _OptionsLoaderState extends State<OptionsLoader> {
  late Future<CatalogOptions> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<CatalogOptions> _load() async {
    final repos = context.read<Repositories>();
    final staff = context.read<AuthNotifier>().can(Op.viewCustomers);
    return CatalogOptions(
      brands: await repos.brands.all(),
      series: await repos.series.all(),
      categories: await repos.categories.all(),
      customers: staff
          ? await repos.customers.all().catchError(
              (_) => <Customer>[],
              test: (e) => e is ForbiddenException,
            )
          : const [],
      sneakers: await repos.sneakers.all(),
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CatalogOptions>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          final colors = Theme.of(context).colorScheme;
          return AppScaffold(
            title: 'Справочники',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Не удалось загрузить справочники',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snap.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const AppScaffold(
            title: 'Справочники',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.builder(context, snap.data!);
      },
    );
  }
}
