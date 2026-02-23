import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';

/// Manages authentication state (current user, JWT token, loading/error).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  /// Attempt login; sets user + token on success, error on failure.
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email, password);
      _token = result['access_token'] as String;
      _user = result['user'] is User
          ? result['user'] as User
          : User.fromJson(result['user'] as Map<String, dynamic>);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Attempt registration; sets user + token on success, error on failure.
  Future<void> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      final result = await _authService.register(email, password, name);
      _token = result['access_token'] as String;
      _user = result['user'] is User
          ? result['user'] as User
          : User.fromJson(result['user'] as Map<String, dynamic>);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all auth state.
  void logout() {
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  /// Toggle loading flag and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
