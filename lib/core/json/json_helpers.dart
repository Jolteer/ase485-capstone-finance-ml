/// Shared helpers for parsing JSON payloads into domain objects.
///
/// Centralises the "field is missing / wrong type / wrong shape" error paths so
/// every model fails with a consistent, structured [ArgumentError] instead of
/// each model throwing whatever ``as String`` or ``num.toDouble`` happens to
/// produce. Previously this logic was duplicated in `_budget_json.dart` and
/// inlined in the other models.
library;

/// Throws [ArgumentError] when [field] is missing or null in [json].
void requireField(Map<String, dynamic> json, String field) {
  if (!json.containsKey(field) || json[field] == null) {
    throw ArgumentError.value(
      json,
      'json',
      'Missing or null required field: $field',
    );
  }
}

/// Returns a non-empty string at [field], else [ArgumentError].
String requireString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw ArgumentError.value(value, field, 'must be a string');
  }
  if (value.isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
  return value;
}

/// Returns a [String] at [field] or [fallback] when the field is missing/null.
///
/// Use for optional string fields where the server may omit a value.
String optionalString(
  Map<String, dynamic> json,
  String field, {
  required String fallback,
}) {
  final value = json[field];
  if (value is String && value.isNotEmpty) return value;
  return fallback;
}

/// Returns a [num] at [field] coerced to [double], else [ArgumentError].
double requireDouble(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! num) {
    throw ArgumentError.value(value, field, 'must be a number');
  }
  return value.toDouble();
}

/// Returns a strictly positive double at [field], else [ArgumentError].
double requirePositive(Map<String, dynamic> json, String field) {
  final value = requireDouble(json, field);
  if (value <= 0) {
    throw ArgumentError.value(value, field, 'must be positive');
  }
  return value;
}

/// Returns a non-negative double at [field], else [ArgumentError].
double requireNonNegative(Map<String, dynamic> json, String field) {
  final value = requireDouble(json, field);
  if (value < 0) {
    throw ArgumentError.value(value, field, 'must be non-negative');
  }
  return value;
}

/// Parses an ISO-8601 timestamp at [field]. Wraps [FormatException] in
/// [ArgumentError] so callers see a uniform error surface.
DateTime requireDateTime(Map<String, dynamic> json, String field) {
  final raw = requireString(json, field);
  try {
    return DateTime.parse(raw);
  } on FormatException catch (e) {
    throw ArgumentError.value(raw, field, 'Invalid date format: ${e.message}');
  }
}
