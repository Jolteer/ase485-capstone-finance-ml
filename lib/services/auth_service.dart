import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/mock_api_client.dart';

/// Handles login, registration, and fetching the current user.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Log in and return a map with 'access_token' and 'user'.
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (useMockApi) {
      return MockApiClient.login(email, password);
    }
    final json = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return {
      'access_token': json['access_token'] as String,
      'user': User.fromJson(json['user'] as Map<String, dynamic>),
    };
  }

  /// Register a new account and return a map with 'access_token' and 'user'.
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    if (useMockApi) {
      return MockApiClient.register(email, password, name);
    }
    final json = await _api.post(
      '/auth/register',
      body: {'email': email, 'password': password, 'name': name},
    );
    return {
      'access_token': json['access_token'] as String,
      'user': User.fromJson(json['user'] as Map<String, dynamic>),
    };
  }

  /// Fetch the currently authenticated user's profile.
  Future<User> getMe() async {
    if (useMockApi) return MockApiClient.getMe();
    final json = await _api.get('/auth/me');
    return User.fromJson(json);
  }
}
