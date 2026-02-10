import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Manages authentication state across the app.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  // TODO: Implement login, signup, logout methods
  // Call notifyListeners() after state changes
}
