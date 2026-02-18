import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';

/// State-management class for authentication.
///
/// Extends [ChangeNotifier] so UI widgets can rebuild whenever the
/// auth state changes (login, logout, error, loading indicator).
///
/// Pattern used by every provider in this app:
/// 1. Set [_isLoading] = true, clear [_error], call [notifyListeners].
/// 2. Await the service call inside a try/catch.
/// 3. On success → update state; on failure → set [_error].
/// 4. Set [_isLoading] = false, call [notifyListeners].
class AuthProvider extends ChangeNotifier {
  /// Underlying service that performs the actual API calls.
  final AuthService _authService;

  /// The currently signed-in user, or null if unauthenticated.
  User? _user;

  /// True while an auth request is in flight (shows a spinner in the UI).
  bool _isLoading = false;

  /// Human-readable error message from the last failed operation.
  String? _error;

  AuthProvider(this._authService);

  // --------------- public getters ---------------

  User? get user => _user;

  /// Convenience check used by route guards / conditional UI.
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --------------- actions ---------------

  /// Attempt to log in with [email] and [password].
  /// On success [_user] is populated and [isAuthenticated] becomes true.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new account. Follows the same loading/error pattern as
  /// [login]. On success the user is automatically signed in.
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(name, email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user. Clears the local [_user] and notifies
  /// listeners so the UI can navigate back to the login screen.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
