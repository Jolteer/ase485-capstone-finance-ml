import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service layer for authentication operations.
/// 
/// Handles user authentication workflows including login, registration,
/// and logout by communicating with the backend API through [ApiClient].
class AuthService {
  /// The API client used for making HTTP requests.
  final ApiClient _api;

  /// Creates an [AuthService] instance with the given [ApiClient].
  AuthService(this._api);

  /// Authenticates a user with email and password.
  /// 
  /// Returns the authenticated [User] on success.
  /// Throws an exception if authentication fails.
  // TODO: Future<User> login(String email, String password)
  
  /// Registers a new user account.
  /// 
  /// Creates a new user with the provided [name], [email], and [password].
  /// Returns the newly created [User] on success.
  /// Throws an exception if registration fails (e.g., email already exists).
  // TODO: Future<User> register(String name, String email, String password)
  
  /// Logs out the current user.
  /// 
  /// Clears authentication tokens and notifies the backend.
  /// Throws an exception if logout fails.
  // TODO: Future<void> logout()
}
