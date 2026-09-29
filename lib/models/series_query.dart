import 'list_query.dart';

class SeriesQuery extends ListQuery<SeriesQuery> {
  static const sortFields = ['name', 'year', 'country'];

  const SeriesQuery({
    super.search,
    super.sortField = 'name',
    super.sortAscending,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
    this.brandId,
  });

  final int? brandId;

  factory SeriesQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'name');
    return SeriesQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: b.sortAscending,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
      brandId: intParam(p, 'brandId'),
    );
  }

  @override
  String get defaultSort => 'name';

  @override
  Map<String, String> get filterParams => {
    if (brandId != null) 'brandId': '$brandId',
  };

  SeriesQuery copyWith({
    String? search,
    Object? brandId = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return SeriesQuery(
      search: search ?? this.search,
      brandId: brandId == _unset ? this.brandId : brandId as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail,
    );
  }

  @override
  SeriesQuery copyBase({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) => copyWith(
    search: search,
    sortField: sortField,
    sortAscending: sortAscending,
    page: page,
    size: size,
    includeDeleted: includeDeleted,
  );

  @override
  SeriesQuery reset() => copyWith(search: '', brandId: null);

  static const _unset = Object();
}
