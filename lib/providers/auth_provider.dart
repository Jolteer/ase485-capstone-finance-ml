import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';

/// Provider for managing authentication state throughout the app.
/// 
/// Extends [ChangeNotifier] to notify listeners when authentication state changes.
/// Tracks the current user, loading state, and any authentication errors.
class AuthProvider extends ChangeNotifier {
  /// The currently authenticated user, or null if not logged in.
  User? _currentUser;
  
  /// Indicates whether an authentication operation is in progress.
  bool _isLoading = false;
  
  /// Stores the most recent authentication error message, if any.
  String? _error;

  /// Returns the currently authenticated user, or null if not logged in.
  User? get currentUser => _currentUser;
  
  /// Returns true if an authentication operation is in progress.
  bool get isLoading => _isLoading;
  
  /// Returns true if a user is currently authenticated.
  bool get isAuthenticated => _currentUser != null;
  
  /// Returns the most recent error message, or null if no error occurred.
  String? get error => _error;

  /// Authenticates a user with the provided credentials.
  /// 
  /// Sets [isLoading] to true during the operation and updates [currentUser]
  /// on success. Sets [error] if authentication fails.
  /// Notifies listeners when state changes.
  // TODO: Future<void> login(String email, String password)
  
  /// Registers a new user account.
  /// 
  /// Creates a new account with the provided [name], [email], and [password].
  /// Sets [isLoading] to true during the operation and updates [currentUser]
  /// on success. Sets [error] if registration fails.
  /// Notifies listeners when state changes.
  // TODO: Future<void> register(String name, String email, String password)
  
  /// Logs out the current user.
  /// 
  /// Clears [currentUser] and any stored authentication tokens.
  /// Notifies listeners after logout is complete.
  // TODO: void logout()
}
