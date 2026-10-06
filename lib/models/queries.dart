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
    this.seriesId,
    this.yearFrom,
    this.yearTo,
  });

  final int? categoryId;
  final int? brandId;
  final int? seriesId;
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
      seriesId: intParam(p, 'seriesId'),
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
    if (seriesId != null) 'seriesId': '$seriesId',
    if (yearFrom != null) 'yearFrom': '$yearFrom',
    if (yearTo != null) 'yearTo': '$yearTo',
  };

  SneakerQuery copyWith({
    String? search,
    Object? categoryId = _unset,
    Object? brandId = _unset,
    Object? seriesId = _unset,
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
      seriesId: seriesId == _unset ? this.seriesId : seriesId as int?,
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
    seriesId: null,
    yearFrom: null,
    yearTo: null,
  );

  static const _unset = Object();
}

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

class BrandQuery extends ListQuery<BrandQuery> {
  static const sortFields = ['name', 'country', 'year'];

  const BrandQuery({
    super.search,
    super.sortField = 'name',
    super.sortAscending,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
  });

  factory BrandQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'name');
    return BrandQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: b.sortAscending,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
    );
  }

  @override
  String get defaultSort => 'name';

  @override
  Map<String, String> get filterParams => const {};

  @override
  BrandQuery copyBase({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) => BrandQuery(
    search: search ?? this.search,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? 1,
    size: size ?? this.size,
    includeDeleted: includeDeleted ?? this.includeDeleted,
    fail: fail,
  );

  @override
  BrandQuery reset() => copyBase(search: '');
}

class CategoryQuery extends ListQuery<CategoryQuery> {
  static const sortFields = ['name'];

  const CategoryQuery({
    super.search,
    super.sortField = 'name',
    super.sortAscending,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
  });

  factory CategoryQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'name');
    return CategoryQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: b.sortAscending,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
    );
  }

  @override
  String get defaultSort => 'name';

  @override
  Map<String, String> get filterParams => const {};

  @override
  CategoryQuery copyBase({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) => CategoryQuery(
    search: search ?? this.search,
    sortField: sortField ?? this.sortField,
    sortAscending: sortAscending ?? this.sortAscending,
    page: page ?? 1,
    size: size ?? this.size,
    includeDeleted: includeDeleted ?? this.includeDeleted,
    fail: fail,
  );

  @override
  CategoryQuery reset() => copyBase(search: '');
}

class CustomerQuery extends ListQuery<CustomerQuery> {
  static const sortFields = ['name', 'city', 'bonus'];

  const CustomerQuery({
    super.search,
    super.sortField = 'name',
    super.sortAscending,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
    this.city,
  });

  final String? city;

  factory CustomerQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'name');
    final city = p['city'];
    return CustomerQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: b.sortAscending,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
      city: (city ?? '').isEmpty ? null : city,
    );
  }

  @override
  String get defaultSort => 'name';

  @override
  Map<String, String> get filterParams => {if (city != null) 'city': city!};

  CustomerQuery copyWith({
    String? search,
    Object? city = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return CustomerQuery(
      search: search ?? this.search,
      city: city == _unset ? this.city : city as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail,
    );
  }

  @override
  CustomerQuery copyBase({
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
  CustomerQuery reset() => copyWith(search: '', city: null);

  static const _unset = Object();
}

class OrderQuery extends ListQuery<OrderQuery> {
  static const sortFields = ['number', 'date', 'total'];

  const OrderQuery({
    super.search,
    super.sortField = 'date',
    super.sortAscending = false,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
    this.status,
    this.customerId,
  });

  final String? status;
  final int? customerId;

  factory OrderQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'date');
    final status = p['status'];
    return OrderQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: p.containsKey('sort') ? b.sortAscending : false,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
      status: (status ?? '').isEmpty ? null : status,
      customerId: intParam(p, 'customerId'),
    );
  }

  @override
  String get defaultSort => 'date';

  @override
  Map<String, String> get filterParams => {
    if (status != null) 'status': status!,
    if (customerId != null) 'customerId': '$customerId',
  };

  OrderQuery copyWith({
    String? search,
    Object? status = _unset,
    Object? customerId = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return OrderQuery(
      search: search ?? this.search,
      status: status == _unset ? this.status : status as String?,
      customerId: customerId == _unset ? this.customerId : customerId as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail,
    );
  }

  @override
  OrderQuery copyBase({
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
  OrderQuery reset() => copyWith(search: '', status: null, customerId: null);

  static const _unset = Object();
}

class ReviewQuery extends ListQuery<ReviewQuery> {
  static const sortFields = ['date', 'rating'];

  const ReviewQuery({
    super.search,
    super.sortField = 'date',
    super.sortAscending = false,
    super.page,
    super.size,
    super.includeDeleted,
    super.fail,
    this.rating,
    this.sneakerId,
  });

  final int? rating;
  final int? sneakerId;

  factory ReviewQuery.fromParams(Map<String, String> p) {
    final b = BaseParams.parse(p, sortFields, 'date');
    return ReviewQuery(
      search: b.search,
      sortField: b.sortField,
      sortAscending: p.containsKey('sort') ? b.sortAscending : false,
      page: b.page,
      size: b.size,
      includeDeleted: b.includeDeleted,
      fail: b.fail,
      rating: intParam(p, 'rating'),
      sneakerId: intParam(p, 'sneakerId'),
    );
  }

  @override
  String get defaultSort => 'date';

  @override
  Map<String, String> get filterParams => {
    if (rating != null) 'rating': '$rating',
    if (sneakerId != null) 'sneakerId': '$sneakerId',
  };

  ReviewQuery copyWith({
    String? search,
    Object? rating = _unset,
    Object? sneakerId = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return ReviewQuery(
      search: search ?? this.search,
      rating: rating == _unset ? this.rating : rating as int?,
      sneakerId: sneakerId == _unset ? this.sneakerId : sneakerId as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail,
    );
  }

  @override
  ReviewQuery copyBase({
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
  ReviewQuery reset() => copyWith(search: '', rating: null, sneakerId: null);

  static const _unset = Object();
}
