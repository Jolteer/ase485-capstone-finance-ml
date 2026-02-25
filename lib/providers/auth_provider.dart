import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';

/// Manages authentication state (current user, loading, errors).
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  // TODO: Future<void> login(String email, String password)
  // TODO: Future<void> register(String name, String email, String password)
  // TODO: void logout()
}
