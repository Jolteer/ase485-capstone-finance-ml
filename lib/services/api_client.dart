/// Shared HTTP client for backend API: base URL, auth token, GET/POST/PUT/DELETE, error extraction.
///
/// All services use this client; configure [AppConstants.apiBaseUrl] at build time.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// Central HTTP client for all API communication.
///
/// Wraps [http.Client] and prepends [AppConstants.apiBaseUrl] to requests.
/// Handles auth token injection and response error mapping.
class ApiClient {
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Base URL for all requests (from [AppConstants.apiBaseUrl]).
  String get baseUrl => AppConstants.apiBaseUrl;

  /// Set the JWT token for authenticated requests. Call after login; clear on logout.
  void setToken(String? token) => _token = token;

  /// Headers for every request: Content-Type: application/json, plus Authorization if [_token] is set.
  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  /// GET request to [path] (relative to baseUrl).
  Future<http.Response> get(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    return _client.get(uri, headers: _headers);
  }

  /// POST request with a JSON [body].
  Future<http.Response> post(String path, {Object? body}) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PUT request with a JSON [body].
  Future<http.Response> put(String path, {Object? body}) {
    return _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE request.
  Future<http.Response> delete(String path) {
    return _client.delete(Uri.parse('$baseUrl$path'), headers: _headers);
  }

  /// Extracts a human-readable error message from an API [response].
  /// Prefers JSON `detail` field when present; otherwise returns a generic message.
  static String extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return (body is Map && body['detail'] != null)
          ? body['detail'] as String
          : 'Request failed';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }

  /// Releases the underlying HTTP client resources.
  void dispose() => _client.close();
}
