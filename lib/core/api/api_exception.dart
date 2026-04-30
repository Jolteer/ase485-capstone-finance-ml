/// Typed exception for HTTP failures coming back from the backend.
///
/// Replaces the old `throw Exception("...")` pattern in services so callers
/// can branch on [statusCode] (e.g. show a custom 401 flow) without parsing
/// strings, while still exposing a human-readable [message] for snackbars.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown by [ApiClient] / services when an HTTP response isn't what we
/// expected. Carries enough context for the UI to react meaningfully.
class ApiException implements Exception {
  /// HTTP status code returned by the backend (e.g. 400, 401, 404, 500).
  final int statusCode;

  /// Human-readable error message extracted from the response body. Falls back
  /// to a generic "Request failed (NNN)" when the body has no recognised shape.
  final String message;

  /// Original response, in case a caller needs the raw body or headers.
  final http.Response? response;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.response,
  });

  /// True when the failure was caused by missing or invalid auth credentials.
  bool get isUnauthorized => statusCode == 401;

  /// True when the resource was not found (or not visible to this user).
  bool get isNotFound => statusCode == 404;

  /// True when the request collided with an existing resource (e.g. duplicate email).
  bool get isConflict => statusCode == 409;

  /// True when the request body failed validation.
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  /// Build an [ApiException] from an HTTP response by trying every known body
  /// shape (FastAPI ``detail`` list, ``detail`` string, ``message``, ``error``).
  factory ApiException.fromResponse(http.Response response) {
    return ApiException(
      statusCode: response.statusCode,
      message: _extractMessage(response),
      response: response,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Parse the most informative message we can from a FastAPI/standard body.
  static String _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        // FastAPI validation: {"detail": [{"loc": [...], "msg": "...", "type": "..."}, ...]}
        final detail = body['detail'];
        if (detail is List) {
          final messages = detail
              .whereType<Map>()
              .map((e) => e['msg'])
              .whereType<String>()
              .toList();
          if (messages.isNotEmpty) return messages.join('; ');
          return 'Validation error (${response.statusCode})';
        }
        for (final key in const ['detail', 'message', 'error']) {
          if (body[key] is String) return body[key] as String;
        }
      }
    } catch (_) {
      // fall through to generic message
    }
    return 'Request failed (${response.statusCode})';
  }
}

/// Thrown when the network is unreachable (no socket, DNS failure, etc).
///
/// Distinct from [ApiException] because there's no HTTP response to inspect;
/// the UI typically shows a "check your connection" message.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
