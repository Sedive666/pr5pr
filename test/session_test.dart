import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_store/core/auth_api.dart';
import 'package:shoe_store/models/app_user.dart';
import 'package:shoe_store/state/auth_notifier.dart';

void main() {
  const user = AppUser(
    id: 3,
    login: 'client',
    name: 'Дмитрий Козлов',
    role: Role.client,
  );

  AuthApi offlineApi() => AuthApi(
    Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:9/api',
        connectTimeout: const Duration(milliseconds: 200),
      ),
    ),
  );

  Future<AuthNotifier> restored({
    required Duration sinceLogin,
    required Duration sinceActivity,
  }) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      AuthNotifier.kAccess: 'access',
      AuthNotifier.kRefresh: 'refresh',
      AuthNotifier.kUser: jsonEncode(user.toJson()),
      AuthNotifier.kLoginAt: now.subtract(sinceLogin).toIso8601String(),
      AuthNotifier.kActivity: now.subtract(sinceActivity).toIso8601String(),
    });
    final auth = AuthNotifier(
      await SharedPreferences.getInstance(),
      offlineApi(),
    );
    await auth.restore();
    return auth;
  }

  test('превышен общий срок сессии — выход с объяснением', () async {
    final auth = await restored(
      sinceLogin: const Duration(hours: 2),
      sinceActivity: Duration.zero,
    );
    expect(auth.isAuthenticated, isFalse);
    expect(auth.endReason, contains('срок'));
  });

  test('долгая неактивность — выход с объяснением', () async {
    final auth = await restored(
      sinceLogin: const Duration(minutes: 1),
      sinceActivity: const Duration(minutes: 30),
    );
    expect(auth.isAuthenticated, isFalse);
    expect(auth.endReason, contains('неактивности'));
  });

  test('сроки не истекли — сессия восстановлена даже без сервера', () async {
    final auth = await restored(
      sinceLogin: const Duration(minutes: 1),
      sinceActivity: const Duration(seconds: 10),
    );
    expect(auth.isAuthenticated, isTrue);
    expect(auth.role, Role.client);
    expect(auth.endReason, isNull);
  });

  test('без сохранённого токена вход не восстанавливается', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthNotifier(
      await SharedPreferences.getInstance(),
      offlineApi(),
    );
    await auth.restore();
    expect(auth.isAuthenticated, isFalse);
  });
}
