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

  /// Base URL sourced from build-time environment variable.
  String get baseUrl => AppConstants.apiBaseUrl;

  /// Set the JWT token for authenticated requests.
  void setToken(String? token) => _token = token;

  /// Common headers for JSON requests (+ auth if available).
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
  static String extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return (body['detail'] ?? 'Request failed') as String;
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }

  /// Releases the underlying HTTP client resources.
  void dispose() => _client.close();
}
