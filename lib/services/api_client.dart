import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// HTTP client for communicating with the FastAPI backend.
/// Handles JSON encoding, auth headers, and error responses.
class ApiClient {
  final String baseUrl;
  String? _accessToken;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  /// Store the JWT token for authenticated requests.
  void setToken(String token) {
    _accessToken = token;
  }

  /// Clear the stored token (logout).
  void clearToken() {
    _accessToken = null;
  }

  /// Build request headers, including the Bearer token if available.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Send a GET request and return the decoded JSON body.
  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Send a POST request with an optional JSON body.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Send a PUT request with an optional JSON body.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Send a DELETE request.
  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Decode a successful response or throw an [ApiException].
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }
}

/// Thrown when the API returns a non-2xx status code.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
