/// Shared HTTP client for backend API: base URL, auth token, GET/POST/PUT/DELETE, error extraction.
///
/// All services use this client; configure [AppConstants.apiBaseUrl] at build time.
/// The JWT token is persisted across restarts via [FlutterSecureStorage]; call
/// [tryRestoreToken] on app startup to re-hydrate the token before any API call.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// Central HTTP client for all API communication.
///
/// Wraps [http.Client] and prepends [AppConstants.apiBaseUrl] to every request.
/// Handles auth token injection, request timeouts, offline detection, and
/// response error mapping. The JWT is persisted in [FlutterSecureStorage] so
/// the user stays logged in across cold starts.
class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _token;

  static const String _kTokenKey = 'auth_token';

  /// Maximum time to wait for any single HTTP request before throwing [TimeoutException].
  static const Duration _defaultTimeout = Duration(seconds: 15);

  ApiClient({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  /// Sets or clears the JWT token for authenticated requests.
  ///
  /// Persists [token] to secure storage (or deletes the stored value when
  /// [token] is null). The in-memory value is updated synchronously; storage
  /// write happens asynchronously as a fire-and-forget side effect.
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _storage.write(key: _kTokenKey, value: token);
    } else {
      _storage.delete(key: _kTokenKey);
    }
  }

  /// Reads the previously persisted token from secure storage and restores it.
  ///
  /// Returns `true` when a token was found and applied; `false` otherwise.
  /// Call this once during app startup (before any authenticated API call).
  Future<bool> tryRestoreToken() async {
    final token = await _storage.read(key: _kTokenKey);
    if (token != null) {
      _token = token;
      return true;
    }
    return false;
  }

  /// Headers for every request: Content-Type JSON, plus Authorization when [_token] is set.
  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  /// Builds a [Uri] for [path] relative to [AppConstants.apiBaseUrl],
  /// optionally appending [queryParams].
  Uri _uri(String path, {Map<String, String>? queryParams}) => Uri.parse(
    '${AppConstants.apiBaseUrl}$path',
  ).replace(queryParameters: queryParams);

  /// Executes [request] and translates [SocketException] into a friendly offline error.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    }
  }

  /// GET request to [path] (relative to baseUrl).
  Future<http.Response> get(String path, {Map<String, String>? queryParams}) =>
      _send(
        () => _client
            .get(_uri(path, queryParams: queryParams), headers: _headers)
            .timeout(_defaultTimeout),
      );

  /// POST request with a JSON [body].
  Future<http.Response> post(String path, {Object? body}) => _send(
    () => _client
        .post(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_defaultTimeout),
  );

  /// PUT request with a JSON [body].
  Future<http.Response> put(String path, {Object? body}) => _send(
    () => _client
        .put(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_defaultTimeout),
  );

  /// DELETE request to [path].
  Future<http.Response> delete(String path) => _send(
    () =>
        _client.delete(_uri(path), headers: _headers).timeout(_defaultTimeout),
  );

  /// Extracts a human-readable error message from an API [response].
  ///
  /// Handles three FastAPI/standard shapes in priority order:
  /// 1. `detail` as a List (FastAPI validation errors) — joins the `msg` fields.
  /// 2. `detail`, `message`, or `error` as a plain String.
  /// 3. Falls back to a generic message with the HTTP status code.
  static String extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        // FastAPI validation errors: {"detail": [{"loc": [...], "msg": "...", "type": "..."}]}
        if (body['detail'] is List) {
          final errors = body['detail'] as List;
          final messages = errors
              .whereType<Map>()
              .map((e) => e['msg'])
              .whereType<String>()
              .toList();
          if (messages.isNotEmpty) return messages.join('; ');
          return 'Validation error (${response.statusCode})';
        }
        for (final key in ['detail', 'message', 'error']) {
          if (body[key] is String) return body[key] as String;
        }
      }
    } catch (_) {
      // fall through to generic message
    }
    return 'Request failed (${response.statusCode})';
  }

  /// Releases the underlying HTTP client resources.
  void dispose() => _client.close();
}
