/// Authentication API: register, login, logout. Returns token and [User]; used by [AuthProvider].
///
/// All methods throw on non-success status; caller should catch and format errors.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Authentication API: register, login (return JWT + user), and client-side logout.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Register a new user. Returns token and [User]. Throws on duplicate email or server error.
  Future<({String token, User user})> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await _api.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    return _parseTokenResponse(res, expected: 201);
  }

  /// Log in by email/password. Returns token and [User]. Throws on invalid credentials or server error.
  Future<({String token, User user})> login(
    String email,
    String password,
  ) async {
    final res = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return _parseTokenResponse(res, expected: 200);
  }

  /// Clear the stored token (client-side only; no API call).
  void logout() {
    _api.setToken(null);
  }

  // Both register and login return {token, user}; share the parse step.
  ({String token, User user}) _parseTokenResponse(
    http.Response res, {
    required int expected,
  }) {
    ApiClient.expectStatus(res, expected);
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return (
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
