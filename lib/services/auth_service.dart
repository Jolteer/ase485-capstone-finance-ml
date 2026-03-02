import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles authentication-related API calls (login, register, logout).
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Register a new user. Returns `{token, user}`.
  Future<({String token, User user})> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await _api.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );

    if (res.statusCode != 201) {
      throw Exception(ApiClient.extractError(res));
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return (
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Log in an existing user. Returns `{token, user}`.
  Future<({String token, User user})> login(
    String email,
    String password,
  ) async {
    final res = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (res.statusCode != 200) {
      throw Exception(ApiClient.extractError(res));
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return (
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Log out (client-side – clears the stored token).
  void logout() {
    _api.setToken(null);
  }
}
