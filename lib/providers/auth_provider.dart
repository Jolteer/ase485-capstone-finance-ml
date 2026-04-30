/// Authentication state and actions (login, register, logout, session restore).
///
/// Backed by [AuthRepository] (which owns the JWT cache and persisted user).
/// Uses [AsyncOperationMixin] for the login/register loading + error pattern,
/// and a separate [tryRestore] path because session restore on cold start
/// must NOT surface an error toast - failure just means "no session yet".
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/repositories/auth_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

class AuthProvider extends ChangeNotifier with AsyncOperationMixin {
  final ApiClient _api;
  final AuthRepository _repository;

  User? _currentUser;

  /// True only while [tryRestore] is running; kept separate from [isLoading]
  /// so screens that key off "auth busy" can distinguish the silent restore
  /// path from an interactive login.
  bool _isRestoring = false;

  AuthProvider({required ApiClient apiClient, AuthRepository? repository})
    : _api = apiClient,
      _repository = repository ?? AuthRepository(apiClient: apiClient);

  /// Shared API client (e.g. so callers can inject the token elsewhere).
  ApiClient get apiClient => _api;

  /// Logged-in user, or null if not authenticated.
  User? get currentUser => _currentUser;

  /// True when [currentUser] is non-null.
  bool get isAuthenticated => _currentUser != null;

  /// True only while session restore is in progress.
  bool get isRestoring => _isRestoring;

  /// Restores a previous session without a network call.
  ///
  /// Reads the persisted JWT and cached user; both must be present. Failure
  /// silently clears any partial state - we don't want a "your session
  /// expired" toast on every cold start that simply has no token yet.
  Future<void> tryRestore() async {
    _isRestoring = true;
    notifyListeners();
    try {
      _currentUser = await _repository.tryRestore();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  /// Signs in with [email] and [password]; sets [currentUser] on success.
  Future<void> login(String email, String password) => runLoad(() async {
    final session = await _repository.login(email, password);
    _currentUser = session.user;
  });

  /// Registers a new user; sets [currentUser] on success.
  Future<void> register(String name, String email, String password) =>
      runLoad(() async {
        final session = await _repository.register(name, email, password);
        _currentUser = session.user;
      });

  /// Clears the in-memory session and erases all persisted auth data.
  void logout() {
    _currentUser = null;
    // Storage delete is fire-and-forget so callers can navigate immediately
    // without waiting on disk I/O.
    _repository.clearSession();
    notifyListeners();
  }
}
