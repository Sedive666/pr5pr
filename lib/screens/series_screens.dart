import 'package:flutter/material.dart';

import '../models/catalog.dart';
import '../models/series.dart';
import '../models/series_query.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_controls.dart';

class SeriesListScreen extends StatelessWidget {
  const SeriesListScreen({super.key, required this.query});

  final SeriesQuery query;

  @override
  Widget build(BuildContext context) {
    return EntityListView<Series, SeriesQuery>(
      title: 'Линейки',
      basePath: '/series',
      query: query,
      searchHint: 'Название или страна',
      columns: [
        TableColumnSpec(
          label: 'Линейка',
          sortField: 'name',
          build: (s) => Text(s.name),
        ),
        TableColumnSpec(
          label: 'Бренд',
          build: (s) => Text(brands[s.brandId] ?? '—'),
        ),
        TableColumnSpec(
          label: 'Страна',
          sortField: 'country',
          build: (s) => Text(s.country),
        ),
        TableColumnSpec(
          label: 'Год запуска',
          sortField: 'year',
          numeric: true,
          build: (s) => Text('${s.launchYear}'),
        ),
      ],
      cardTitle: (s) => s.name,
      cardSubtitle: (s) =>
          '${brands[s.brandId]} · ${s.country} · с ${s.launchYear} г.',
      filters: (q, apply) => [
        FilterDropdown<int>(
          label: 'Бренд',
          value: q.brandId,
          options: brands,
          onChanged: (v) => apply(q.copyWith(brandId: v)),
        ),
      ],
    );
  }
}

class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailView<Series, SeriesQuery>(
      id: id,
      listPath: '/series',
      title: (s) => s.name,
      fields: (s) => [
        ('Бренд', brands[s.brandId] ?? '—'),
        ('Страна', s.country),
        ('Год запуска', '${s.launchYear}'),
      ],
    );
  }
}
