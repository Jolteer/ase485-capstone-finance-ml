/// Auth repository - manages the current session, JWT, and cached user.
///
/// Wraps the lower-level [AuthService] and the secure-storage IO so that
/// [AuthProvider] can stay focused on UI state (loading flag, error string).
/// Distinct from the other repositories because authentication is the only
/// place that owns persistent client-side state beyond an in-memory list.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';

/// Result of a successful login/register call.
class AuthSession {
  final String token;
  final User user;
  const AuthSession({required this.token, required this.user});
}

class AuthRepository {
  final ApiClient _api;
  final AuthService _service;
  final FlutterSecureStorage _storage;

  /// Storage key for the cached [User] JSON; the JWT lives in [ApiClient].
  static const String _kUserKey = 'auth_user';

  AuthRepository({
    required ApiClient apiClient,
    AuthService? service,
    FlutterSecureStorage? storage,
  }) : _api = apiClient,
       _service = service ?? AuthService(apiClient),
       _storage = storage ?? const FlutterSecureStorage();

  /// Run a login request; on success persist the token + cached user.
  Future<AuthSession> login(String email, String password) async {
    final result = await _service.login(email, password);
    await _persistSession(result.token, result.user);
    return AuthSession(token: result.token, user: result.user);
  }

  /// Run a register request; on success persist the token + cached user.
  Future<AuthSession> register(
    String name,
    String email,
    String password,
  ) async {
    final result = await _service.register(name, email, password);
    await _persistSession(result.token, result.user);
    return AuthSession(token: result.token, user: result.user);
  }

  /// Try to re-hydrate a previous session without making a network call.
  ///
  /// Returns the cached [User] if both the JWT and user record are present;
  /// otherwise wipes the partial state so the next launch starts clean.
  Future<User?> tryRestore() async {
    final hasToken = await _api.tryRestoreToken();
    if (!hasToken) return null;
    final userJson = await _storage.read(key: _kUserKey);
    if (userJson == null) {
      _api.setToken(null);
      return null;
    }
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      // Cached payload is malformed; treat as "no session".
      await _storage.delete(key: _kUserKey);
      _api.setToken(null);
      return null;
    }
  }

  /// Wipes the in-memory token and the cached user from storage.
  Future<void> clearSession() async {
    _service.logout();
    await _storage.delete(key: _kUserKey);
  }

  Future<void> _persistSession(String token, User user) async {
    _api.setToken(token);
    await _storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
  }
}
