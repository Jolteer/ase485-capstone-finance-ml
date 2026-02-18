import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// Low-level HTTP client that all service classes use to talk to the
/// FastAPI backend.
///
/// Responsibilities:
/// 1. Build the full URL from [baseUrl] + a relative path.
/// 2. Attach JSON content-type and (optionally) a Bearer auth token.
/// 3. Enforce a per-request timeout via [AppConstants.apiTimeout].
/// 4. Decode successful JSON responses or throw an [ApiException].
///
/// Usage:
/// ```dart
/// final api = ApiClient();              // defaults to localhost
/// api.setAuthToken(jwt);                // after login
/// final data = await api.get('/budgets');
/// ```
class ApiClient {
  /// The underlying HTTP client (injectable for testing).
  final http.Client _client;

  /// Root URL for every request (e.g. `http://localhost:8000/api/v1`).
  final String baseUrl;

  /// JWT token attached as a Bearer header on authenticated requests.
  /// Null until [setAuthToken] is called after a successful login.
  String? _authToken;

  /// Creates an [ApiClient].
  ///
  /// [client] – optional custom [http.Client], useful for injecting a
  ///   mock client during unit tests.
  /// [baseUrl] – defaults to [AppConstants.apiBaseUrl].
  ApiClient({http.Client? client, this.baseUrl = AppConstants.apiBaseUrl})
    : _client = client ?? http.Client();

  /// Store the JWT token so subsequent requests include it in headers.
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Remove the stored token (called on logout).
  void clearAuthToken() {
    _authToken = null;
  }

  /// Default headers sent with every request.
  /// Includes the Authorization header only when a token is present.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Send a GET request to [path] and return the decoded JSON body.
  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  /// Send a POST request with a JSON [body] and return the decoded response.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  /// Send a PUT request (full update) with a JSON [body].
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .put(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  /// Send a DELETE request. Returns nothing on success.
  Future<void> delete(String path) async {
    final response = await _client
        .delete(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(AppConstants.apiTimeout);
    _handleResponse(response);
  }

  /// Check the HTTP status code.
  /// • 2xx → decode and return the JSON body (empty map if body is blank).
  /// • Anything else → throw an [ApiException] with the status and message.
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }

  /// Close the underlying HTTP client. Call this when the app shuts down
  /// to free resources.
  void dispose() {
    _client.close();
  }
}

/// Exception thrown when the API returns a non-2xx status code.
///
/// Contains the HTTP [statusCode] and the raw response [message] body
/// for debugging.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
