/// Authentication state and actions (login, register, logout, session restore).
///
/// Use with [ChangeNotifierProvider] or [ListenableProvider]. Exposes
/// [currentUser], [isLoading], [error], and methods that notify listeners.
///
/// Call [tryRestore] once at app startup to re-hydrate the session from
/// [FlutterSecureStorage] without requiring the user to log in again.
library;

import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages authentication state: current user, loading flag, and error message.
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final AuthService _authService;
  final FlutterSecureStorage _userStorage;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  static const String _kUserKey = 'auth_user';

  /// [apiClient] is required for token management after login.
  /// Pass [service] or [userStorage] in tests to inject mocks.
  AuthProvider({
    required ApiClient apiClient,
    AuthService? service,
    FlutterSecureStorage? userStorage,
  }) : _api = apiClient,
       _authService = service ?? AuthService(apiClient),
       _userStorage = userStorage ?? const FlutterSecureStorage();

  /// Shared API client (e.g. for setting token after login).
  ApiClient get apiClient => _api;

  /// Logged-in user, or null if not authenticated.
  User? get currentUser => _currentUser;

  /// True while a login, register, or session-restore request is in progress.
  bool get isLoading => _isLoading;

  /// True when [currentUser] is non-null.
  bool get isAuthenticated => _currentUser != null;

  /// Last error message from login/register, or null. Clear with [clearError].
  String? get error => _error;

  /// Clears [error] and notifies listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Restores the session from secure storage without a network call.
  ///
  /// Reads the persisted JWT via [ApiClient.tryRestoreToken] and the cached
  /// [User] JSON from storage. Both must exist for the session to be valid; if
  /// either is missing the stored data is cleared so the next launch starts
  /// fresh. Call this once at app startup before navigating.
  Future<void> tryRestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _api.tryRestoreToken();
      if (hasToken) {
        final userJson = await _userStorage.read(key: _kUserKey);
        if (userJson != null) {
          _currentUser = User.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>,
          );
        } else {
          // Token without cached user — treat session as invalid.
          _api.setToken(null);
        }
      }
    } catch (_) {
      _currentUser = null;
      _api.setToken(null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs in with [email] and [password]; sets [currentUser] and token on success.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _api.setToken(result.token);
      _currentUser = result.user;
      await _userStorage.write(
        key: _kUserKey,
        value: jsonEncode(_currentUser!.toJson()),
      );
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user; sets [currentUser] and token on success.
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(name, email, password);
      _api.setToken(result.token);
      _currentUser = result.user;
      await _userStorage.write(
        key: _kUserKey,
        value: jsonEncode(_currentUser!.toJson()),
      );
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the in-memory session and erases all persisted auth data.
  ///
  /// The token and user cache are deleted from secure storage as a
  /// fire-and-forget operation so the call remains synchronous; callers
  /// can navigate immediately without awaiting storage completion.
  void logout() {
    _authService.logout();
    unawaited(_userStorage.delete(key: _kUserKey));
    _currentUser = null;
    notifyListeners();
  }
}
