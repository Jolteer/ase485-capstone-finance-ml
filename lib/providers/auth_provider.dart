import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages authentication state (current user, loading, errors).
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  late final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _authService = AuthService(_api);
  }

  ApiClient get apiClient => _api;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  /// Clears any previous error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

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

  void logout() {
    _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
