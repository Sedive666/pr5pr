import 'package:dio/dio.dart';

import '../models/app_user.dart';
import 'api_client.dart';
import 'api_exceptions.dart';

class AuthResult {
  const AuthResult(this.accessToken, this.refreshToken, this.user);

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    json['accessToken'] as String,
    json['refreshToken'] as String,
    AppUser.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String accessToken;
  final String refreshToken;
  final AppUser user;
}

class AuthApi {
  AuthApi([Dio? dio]) : _dio = dio ?? buildDio();

  final Dio _dio;

  Future<AuthResult> _post(String path, Map<String, dynamic> body) =>
      guard(() async {
        final response = await _dio.post(path, data: body);
        return AuthResult.fromJson(response.data as Map<String, dynamic>);
      });

  Future<AuthResult> login(String login, String password) =>
      _post('/auth/login', {'login': login, 'password': password});

  Future<AuthResult> register(String login, String password, String name) =>
      _post('/auth/register', {
        'login': login,
        'password': password,
        'name': name,
      });

  Future<AuthResult> refresh(String refreshToken) =>
      _post('/auth/refresh', {'refreshToken': refreshToken});

  Future<AppUser> me(String accessToken) => guard(() async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  });

  Future<void> logout(String refreshToken) => guard(() async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  });
}
