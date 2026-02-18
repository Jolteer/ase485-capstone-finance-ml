import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service that handles user authentication against the FastAPI backend.
///
/// • [login]          – authenticates with email/password and stores the JWT.
/// • [register]       – creates a new account, then stores the JWT.
/// • [logout]         – invalidates the session and clears the local JWT.
/// • [getCurrentUser] – fetches the currently authenticated user profile.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// POST email and password to the login endpoint.
  /// On success the API returns a JWT token and the user profile.
  /// The token is stored in [ApiClient] so all subsequent requests are
  /// automatically authenticated.
  Future<User> login(String email, String password) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    // Persist the token for future authenticated requests.
    _api.setAuthToken(data['token'] as String);
    // Parse and return the nested user object.
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// POST name, email, and password to the registration endpoint.
  /// Works the same as [login] — stores the token and returns the new user.
  Future<User> register(String name, String email, String password) async {
    final data = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    _api.setAuthToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Notify the backend that the user is logging out, then clear the local
  /// JWT so the app returns to an unauthenticated state.
  Future<void> logout() async {
    await _api.post('/auth/logout', {});
    _api.clearAuthToken();
  }

  /// GET the profile of the currently authenticated user.
  /// Useful for restoring session state on app restart.
  Future<User> getCurrentUser() async {
    final data = await _api.get('/auth/me');
    return User.fromJson(data);
  }
}
