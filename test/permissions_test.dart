import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_store/core/permissions.dart';
import 'package:shoe_store/models/app_user.dart';
import 'package:shoe_store/models/validators.dart';

void main() {
  group('Матрица прав: роль → операция', () {
    test('гость не может ничего', () {
      for (final op in Op.values) {
        expect(can(null, op), isFalse, reason: op.name);
      }
    });

    test('покупатель видит каталог и свои заказы, но не управляет', () {
      expect(can(Role.client, Op.viewCatalog), isTrue);
      expect(can(Role.client, Op.viewOwnOrders), isTrue);
      expect(can(Role.client, Op.cancelOwnOrder), isTrue);
      expect(can(Role.client, Op.editRecords), isFalse);
      expect(can(Role.client, Op.viewCustomers), isFalse);
      expect(can(Role.client, Op.hardDelete), isFalse);
    });

    test(
      'менеджер ведёт записи, но не удаляет навсегда и не восстанавливает',
      () {
        expect(can(Role.manager, Op.editRecords), isTrue);
        expect(can(Role.manager, Op.softDelete), isTrue);
        expect(can(Role.manager, Op.viewOrders), isTrue);
        expect(can(Role.manager, Op.hardDelete), isFalse);
        expect(can(Role.manager, Op.restore), isFalse);
        expect(can(Role.manager, Op.manageUsers), isFalse);
      },
    );

    test(
      'только администратор управляет пользователями и видит статистику',
      () {
        for (final op in [
          Op.manageUsers,
          Op.viewStats,
          Op.restore,
          Op.hardDelete,
        ]) {
          expect(can(Role.admin, op), isTrue, reason: op.name);
          expect(can(Role.manager, op), isFalse, reason: op.name);
          expect(can(Role.client, op), isFalse, reason: op.name);
        }
      },
    );

    test('у каждой роли есть операция, недоступная остальным', () {
      for (final role in Role.values) {
        final own = rolePermissions[role]!.where(
          (op) => Role.values.where((r) => r != role).every((r) => !can(r, op)),
        );
        expect(own, isNotEmpty, reason: role.name);
      }
    });
  });

  group('Защита маршрутов (redirect)', () {
    String? go(Role? role, String location) =>
        guardRedirect(role: role, uri: Uri.parse(location));

    test('гостя отправляет на вход с запоминанием адреса', () {
      expect(go(null, '/orders/3'), '/login?from=%2Forders%2F3');
      expect(go(null, '/login'), isNull);
      expect(go(null, '/register'), isNull);
    });

    test(
      'после входа возвращает на запомненный адрес, но не на чужой сайт',
      () {
        expect(go(Role.manager, '/login?from=%2Forders%2F3'), '/orders/3');
        expect(go(Role.manager, '/login?from=//evil.example'), '/sneakers');
      },
    );

    test('главная зависит от роли', () {
      expect(go(Role.client, '/'), '/my/orders');
      expect(go(Role.manager, '/'), '/sneakers');
      expect(go(Role.admin, '/'), '/admin/stats');
    });

    test('чужой адрес, введённый вручную, ведёт на экран отказа', () {
      expect(go(Role.client, '/admin/users'), startsWith('/forbidden'));
      expect(go(Role.client, '/sneakers/new'), startsWith('/forbidden'));
      expect(go(Role.manager, '/admin/stats'), startsWith('/forbidden'));
      expect(go(Role.admin, '/brands/2/edit'), startsWith('/forbidden'));
      expect(go(Role.manager, '/my/orders'), startsWith('/forbidden'));
    });

    test('свои адреса открываются без перенаправления', () {
      expect(go(Role.client, '/sneakers/5'), isNull);
      expect(go(Role.manager, '/sneakers/5/edit'), isNull);
      expect(go(Role.admin, '/admin/users'), isNull);
    });
  });

  test('усиленная проверка пароля', () {
    expect(strongPassword('short1!'), isNotNull);
    expect(strongPassword('longpassword!'), isNotNull);
    expect(strongPassword('longpassword1'), isNotNull);
    expect(strongPassword('Sneaker2025!'), isNull);
  });
}
