/// Shared HTTP client for the SmartSpend backend.
///
/// Wraps [http.Client] with the conventions every service needs:
/// - prepends [AppConstants.apiBaseUrl] to every path,
/// - injects ``Authorization: Bearer <token>`` when set,
/// - applies a default request timeout,
/// - converts [SocketException] into [NetworkException] for the UI,
/// - converts non-success HTTP responses into [ApiException] via [expectStatus]
///   / [decodeJsonList] / [decodeJsonObject] so callers can branch on
///   [ApiException.statusCode] instead of parsing string messages.
///
/// The JWT is persisted in [FlutterSecureStorage] via [setToken] /
/// [tryRestoreToken] so the user stays signed in across cold starts.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/core/api/api_exception.dart';

/// Central HTTP client for all API communication.
class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _token;

  static const String _kTokenKey = 'auth_token';

  /// Maximum time to wait for any single HTTP request before throwing.
  static const Duration _defaultTimeout = Duration(seconds: 15);

  ApiClient({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  // ── Token management ─────────────────────────────────────────────────────

  /// Sets or clears the JWT token used to authenticate requests.
  ///
  /// In-memory state is updated synchronously so subsequent calls already
  /// carry the new token; the secure-storage write is fire-and-forget so the
  /// caller doesn't have to await disk I/O.
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _storage.write(key: _kTokenKey, value: token);
    } else {
      _storage.delete(key: _kTokenKey);
    }
  }

  /// Reads the persisted token from secure storage and applies it.
  ///
  /// Returns `true` when a token was found, `false` otherwise. Call once at
  /// app startup before any authenticated API call.
  Future<bool> tryRestoreToken() async {
    final token = await _storage.read(key: _kTokenKey);
    if (token == null) return false;
    _token = token;
    return true;
  }

  // ── Request helpers ──────────────────────────────────────────────────────

  /// Headers for every request: JSON content-type + bearer auth when set.
  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  /// Builds the absolute URL for [path] (relative to [AppConstants.apiBaseUrl]).
  Uri _uri(String path, {Map<String, String>? queryParams}) => Uri.parse(
    '${AppConstants.apiBaseUrl}$path',
  ).replace(queryParameters: queryParams);

  /// Executes [request], translating [SocketException] / [TimeoutException]
  /// into [NetworkException] so the UI gets a friendly "no connection"
  /// message instead of a stack trace.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw const NetworkException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const NetworkException('Request timed out. Please try again.');
    }
  }

  /// GET request to [path] (relative to [AppConstants.apiBaseUrl]).
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

  /// DELETE request.
  Future<http.Response> delete(String path) => _send(
    () =>
        _client.delete(_uri(path), headers: _headers).timeout(_defaultTimeout),
  );

  // ── Status / decoding helpers ────────────────────────────────────────────

  /// Throws [ApiException] when [res.statusCode] doesn't match [expected].
  static void expectStatus(http.Response res, int expected) {
    if (res.statusCode != expected) {
      throw ApiException.fromResponse(res);
    }
  }

  /// Verifies status, decodes a JSON list, parses each entry through [parse].
  ///
  /// On non-[expected] status throws [ApiException]. Default expected is 200.
  static List<T> decodeJsonList<T>(
    http.Response res,
    T Function(Map<String, dynamic>) parse, {
    int expected = 200,
  }) {
    expectStatus(res, expected);
    final list = jsonDecode(res.body) as List;
    return list.map((j) => parse(j as Map<String, dynamic>)).toList();
  }

  /// Verifies status, decodes a JSON object, parses it through [parse].
  ///
  /// Use [expected]: 201 for create endpoints. Throws [ApiException] otherwise.
  static T decodeJsonObject<T>(
    http.Response res,
    T Function(Map<String, dynamic>) parse, {
    int expected = 200,
  }) {
    expectStatus(res, expected);
    return parse(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Releases the underlying HTTP client.
  void dispose() => _client.close();
}
