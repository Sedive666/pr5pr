import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../core/config.dart';
import '../core/permissions.dart' as perm;
import '../models/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  static const kAccess = 'auth_access_token';
  static const kRefresh = 'auth_refresh_token';
  static const kUser = 'auth_user';
  static const kLoginAt = 'auth_login_at';
  static const kActivity = 'auth_last_activity';

  AuthNotifier(this._prefs, this._api, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  @visibleForTesting
  AuthNotifier.signedIn(this._prefs, this._api, AppUser user)
    : _now = DateTime.now,
      _user = user,
      _accessToken = 'test',
      _loginAt = DateTime.now();

  final SharedPreferences _prefs;
  final AuthApi _api;
  final DateTime Function() _now;

  AppUser? _user;
  String? _accessToken;
  DateTime? _loginAt;
  DateTime? _activityWritten;
  Future<bool>? _refreshing;

  String? endReason;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null;
  Role? get role => _user?.role;
  bool can(perm.Op op) => perm.can(role, op);
  DateTime? get sessionEndsAt => _loginAt?.add(sessionMaxDuration);

  Future<void> restore() async {
    final access = _prefs.getString(kAccess);
    final cached = _prefs.getString(kUser);
    if (access == null || cached == null) return;

    final now = _now();
    final loginAt = DateTime.tryParse(_prefs.getString(kLoginAt) ?? '');
    final last = DateTime.tryParse(_prefs.getString(kActivity) ?? '');
    if (loginAt == null || now.difference(loginAt) >= sessionMaxDuration) {
      return _clear('Сессия завершена: истёк максимальный срок работы');
    }
    if (last != null && now.difference(last) >= inactivityTimeout) {
      return _clear('Сессия завершена из-за неактивности');
    }

    try {
      _user = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return _clear(null);
    }
    _accessToken = access;
    _loginAt = loginAt;

    try {
      await _api.me(access);
    } on UnauthorizedException {
      if (!await refreshTokens()) return;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> login(String login, String password) async =>
      _start(await _api.login(login, password));

  Future<void> register(String login, String password, String name) async =>
      _start(await _api.register(login, password, name));

  Future<void> _start(AuthResult result) async {
    endReason = null;
    _loginAt = _now();
    await _prefs.setString(kLoginAt, _loginAt!.toIso8601String());
    await markActivity(force: true);
    await _save(result);
    notifyListeners();
  }

  Future<void> _save(AuthResult result) async {
    _accessToken = result.accessToken;
    _user = result.user;
    await _prefs.setString(kAccess, result.accessToken);
    await _prefs.setString(kRefresh, result.refreshToken);
    await _prefs.setString(kUser, jsonEncode(result.user.toJson()));
  }

  Future<bool> refreshTokens() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refresh = _prefs.getString(kRefresh);
    if (refresh == null) {
      await _clear('Сессия истекла, войдите заново');
      return false;
    }
    try {
      await _save(await _api.refresh(refresh));
      if (kDebugMode) debugPrint('[AUTH] токен доступа обновлён');
      notifyListeners();
      return true;
    } on UnauthorizedException {
      await _clear('Сессия истекла, войдите заново');
      return false;
    } on ApiException {
      return false;
    }
  }

  Future<void> logout({String? reason}) async {
    final refresh = _prefs.getString(kRefresh);
    if (refresh != null) _api.logout(refresh).ignore();
    await _clear(reason);
  }

  Future<void> _clear(String? reason) async {
    _user = null;
    _accessToken = null;
    _loginAt = null;
    endReason = reason;
    for (final key in [kAccess, kRefresh, kUser, kLoginAt, kActivity]) {
      await _prefs.remove(key);
    }
    notifyListeners();
  }

  Future<void> markActivity({bool force = false}) async {
    final now = _now();
    if (!force &&
        _activityWritten != null &&
        now.difference(_activityWritten!) < const Duration(seconds: 5)) {
      return;
    }
    _activityWritten = now;
    await _prefs.setString(kActivity, now.toIso8601String());
  }
}
