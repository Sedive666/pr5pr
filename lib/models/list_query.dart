import 'package:flutter/foundation.dart';

const pageSizes = [10, 25, 50];

abstract class ListQuery<Q extends ListQuery<Q>> {
  const ListQuery({
    this.search = '',
    required this.sortField,
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.fail = false,
  });

  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool fail;

  String get defaultSort;
  Map<String, String> get filterParams;
  bool get hasFilters => filterParams.isNotEmpty || search.isNotEmpty;

  Q copyBase({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  });

  Q reset();

  Map<String, String> toParams() => {
    if (search.isNotEmpty) 'search': search,
    ...filterParams,
    if (sortField != defaultSort || !sortAscending)
      'sort': '$sortField,${sortAscending ? 'asc' : 'desc'}',
    if (page != 1) 'page': '$page',
    if (size != 10) 'size': '$size',
    if (includeDeleted) 'deleted': '1',
    if (fail) 'fail': '1',
  };

  bool sameAs(ListQuery other) => mapEquals(toParams(), other.toParams());
}

class BaseParams {
  const BaseParams._(
    this.search,
    this.sortField,
    this.sortAscending,
    this.page,
    this.size,
    this.includeDeleted,
    this.fail,
  );

  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool fail;

  factory BaseParams.parse(
    Map<String, String> p,
    List<String> sortFields,
    String defaultSort,
  ) {
    final sort = (p['sort'] ?? '').split(',');
    final known = sortFields.contains(sort.first);
    final page = int.tryParse(p['page'] ?? '') ?? 1;
    final size = int.tryParse(p['size'] ?? '') ?? 10;
    return BaseParams._(
      p['search'] ?? '',
      known ? sort.first : defaultSort,
      !known || sort.length < 2 || sort[1] != 'desc',
      page < 1 ? 1 : page,
      pageSizes.contains(size) ? size : 10,
      p['deleted'] == '1',
      p['fail'] == '1',
    );
  }
}

int? intParam(Map<String, String> p, String key) => int.tryParse(p[key] ?? '');
