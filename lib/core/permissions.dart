import '../models/app_user.dart';

enum Op {
  viewCatalog,
  viewOwnOrders,
  cancelOwnOrder,
  viewCustomers,
  viewOrders,
  editRecords,
  softDelete,
  viewDeleted,
  restore,
  hardDelete,
  manageUsers,
  viewStats,
}

const rolePermissions = <Role, Set<Op>>{
  Role.client: {Op.viewCatalog, Op.viewOwnOrders, Op.cancelOwnOrder},
  Role.manager: {
    Op.viewCatalog,
    Op.viewCustomers,
    Op.viewOrders,
    Op.editRecords,
    Op.softDelete,
  },
  Role.admin: {
    Op.viewCatalog,
    Op.viewCustomers,
    Op.viewOrders,
    Op.viewDeleted,
    Op.restore,
    Op.hardDelete,
    Op.manageUsers,
    Op.viewStats,
  },
};

bool can(Role? role, Op op) =>
    role != null && (rolePermissions[role]?.contains(op) ?? false);

Op? requiredOp(String path) {
  final s = path.split('/').where((p) => p.isNotEmpty).toList();
  if (s.isEmpty) return null;
  if (s.length > 1 && (s.last == 'new' || s.last == 'edit')) {
    return Op.editRecords;
  }
  return switch (s.first) {
    'sneakers' ||
    'brands' ||
    'series' ||
    'categories' ||
    'reviews' => Op.viewCatalog,
    'customers' => Op.viewCustomers,
    'orders' => Op.viewOrders,
    'my' => Op.viewOwnOrders,
    'admin' => s.length > 1 && s[1] == 'stats' ? Op.viewStats : Op.manageUsers,
    _ => null,
  };
}

String homeFor(Role role) => switch (role) {
  Role.client => '/my/orders',
  Role.manager => '/sneakers',
  Role.admin => '/admin/stats',
};

const publicPaths = {'/login', '/register'};

String? _safeFrom(String? from) =>
    from != null && from.startsWith('/') && !from.startsWith('//')
    ? from
    : null;

String? guardRedirect({required Role? role, required Uri uri}) {
  final path = uri.path;
  final isPublic = publicPaths.contains(path);
  if (role == null) {
    if (isPublic) return null;
    return path == '/'
        ? '/login'
        : '/login?from=${Uri.encodeComponent(uri.toString())}';
  }
  if (isPublic) return _safeFrom(uri.queryParameters['from']) ?? homeFor(role);
  if (path == '/') return homeFor(role);
  final op = requiredOp(path);
  if (op != null && !can(role, op)) {
    return '/forbidden?path=${Uri.encodeComponent(uri.toString())}';
  }
  return null;
}
