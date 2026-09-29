import 'list_query.dart';

class SneakerQuery extends ListQuery<SneakerQuery> {
  static const sortFields = ['name', 'year', 'price', 'stock'];

  const SneakerQuery({
    super.search,
    super.sortField = 'name',
    super.sortAscending,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
    this.categoryId,
    this.brandId,
    this.yearFrom,
    this.yearTo,
  });

  final int? categoryId;
  final int? brandId;
  final int? yearFrom;
  final int? yearTo;

  factory SneakerQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'name');
    return SneakerQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: b.sortAscending,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
      categoryId: intParam(p, 'categoryId'),
      brandId: intParam(p, 'brandId'),
      yearFrom: intParam(p, 'yearFrom'),
      yearTo: intParam(p, 'yearTo'),
    );
  }

  @override
  String get defaultSort => 'name';

  @override
  Map<String, String> get filterParams => {
    if (categoryId != null) 'categoryId': '$categoryId',
    if (brandId != null) 'brandId': '$brandId',
    if (yearFrom != null) 'yearFrom': '$yearFrom',
    if (yearTo != null) 'yearTo': '$yearTo',
  };

  SneakerQuery copyWith({
    String? search,
    Object? categoryId = _unset,
    Object? brandId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return SneakerQuery(
      search: search ?? this.search,
      categoryId: categoryId == _unset ? this.categoryId : categoryId as int?,
      brandId: brandId == _unset ? this.brandId : brandId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail,
    );
  }

  @override
  SneakerQuery copyBase({
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
  SneakerQuery reset() => copyWith(
    search: '',
    categoryId: null,
    brandId: null,
    yearFrom: null,
    yearTo: null,
  );

  static const _unset = Object();
}
