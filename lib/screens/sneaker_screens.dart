import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/catalog.dart';
import '../models/sneaker.dart';
import '../models/sneaker_query.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_controls.dart';

final _years = {for (var y = 2017; y <= 2024; y++) y: '$y'};

class SneakerListScreen extends StatelessWidget {
  const SneakerListScreen({super.key, required this.query});

  final SneakerQuery query;

  @override
  Widget build(BuildContext context) {
    return EntityListView<Sneaker, SneakerQuery>(
      title: 'Кроссовки',
      basePath: '/sneakers',
      query: query,
      searchHint: 'Название или артикул',
      columns: [
        TableColumnSpec(
          label: 'Модель',
          sortField: 'name',
          build: (s) => Text(s.name),
        ),
        TableColumnSpec(label: 'Артикул', build: (s) => Text(s.sku)),
        TableColumnSpec(
          label: 'Бренд',
          build: (s) => Text(brands[s.brandId] ?? '—'),
        ),
        TableColumnSpec(
          label: 'Категория',
          build: (s) => Text(categories[s.categoryId] ?? '—'),
        ),
        TableColumnSpec(
          label: 'Год',
          sortField: 'year',
          numeric: true,
          build: (s) => Text('${s.year}'),
        ),
        TableColumnSpec(
          label: 'Цена, ₽',
          sortField: 'price',
          numeric: true,
          build: (s) => Text(formatPrice(s.price)),
        ),
        TableColumnSpec(
          label: 'В наличии',
          sortField: 'stock',
          numeric: true,
          build: (s) => Text('${s.stockAvailable} из ${s.stockTotal}'),
        ),
      ],
      cardTitle: (s) => s.name,
      cardSubtitle: (s) =>
          '${brands[s.brandId]} · ${s.sku} · ${s.year} г. · ${formatPrice(s.price)} ₽',
      filters: (q, apply) => [
        FilterDropdown<int>(
          label: 'Бренд',
          value: q.brandId,
          options: brands,
          onChanged: (v) => apply(q.copyWith(brandId: v)),
        ),
        FilterDropdown<int>(
          label: 'Категория',
          value: q.categoryId,
          options: categories,
          onChanged: (v) => apply(q.copyWith(categoryId: v)),
        ),
        FilterDropdown<int>(
          label: 'Год от',
          value: q.yearFrom,
          options: _years,
          onChanged: (v) => apply(q.copyWith(yearFrom: v)),
        ),
        FilterDropdown<int>(
          label: 'Год до',
          value: q.yearTo,
          options: _years,
          onChanged: (v) => apply(q.copyWith(yearTo: v)),
        ),
      ],
    );
  }
}

class SneakerDetailScreen extends StatelessWidget {
  const SneakerDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailView<Sneaker, SneakerQuery>(
      id: id,
      listPath: '/sneakers',
      title: (s) => s.name,
      fields: (s) => [
        ('Артикул', s.sku),
        ('Бренд', brands[s.brandId] ?? '—'),
        ('Категория', categories[s.categoryId] ?? '—'),
        ('Год выпуска', '${s.year}'),
        ('Цена', '${formatPrice(s.price)} ₽'),
        ('В наличии', '${s.stockAvailable} пар из ${s.stockTotal}'),
      ],
      extra: (context, s) => TextButton.icon(
        onPressed: () => context.push('/series/${s.seriesId}'),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Открыть линейку'),
      ),
    );
  }
}
