import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/series.dart';
import '../models/sneaker.dart';
import '../repositories/repositories.dart';
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

class OptionsLoader extends StatelessWidget {
  const OptionsLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, CatalogOptions options) builder;

  Future<CatalogOptions> _load(Repositories repos) async => CatalogOptions(
    brands: await repos.brands.all(),
    series: await repos.series.all(),
    categories: await repos.categories.all(),
    customers: await repos.customers.all(),
    sneakers: await repos.sneakers.all(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CatalogOptions>(
      future: _load(context.read<Repositories>()),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const AppScaffold(
            title: 'Форма',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return builder(context, snap.data!);
      },
    );
  }
}
