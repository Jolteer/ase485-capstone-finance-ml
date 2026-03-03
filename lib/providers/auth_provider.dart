/// Authentication state and actions (login, register, logout).
///
/// Use with [ChangeNotifierProvider] or [ListenableProvider]. Exposes
/// [currentUser], [isLoading], [error], and methods that notify listeners.
import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages authentication state: current user, loading flag, and error message.
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  late final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiClient apiClient}) : _api = apiClient {
    _authService = AuthService(_api);
  }

  /// Shared API client (e.g. for setting token after login).
  ApiClient get apiClient => _api;

  /// Logged-in user, or null if not authenticated.
  User? get currentUser => _currentUser;

  /// True while a login or register request is in progress.
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

  /// Signs in with [email] and [password]; sets [currentUser] and token on success.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _api.setToken(result.token);
      _currentUser = result.user;
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
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears token and [currentUser]; use after sign-out.
  void logout() {
    _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
