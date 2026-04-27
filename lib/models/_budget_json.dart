/// JSON validation helpers for [Budget].
///
/// Extracted from `budget.dart` to keep the model file focused on the value
/// type and copy/equality semantics. The helpers throw [ArgumentError] (or a
/// wrapped [FormatException] for dates) so the model surfaces invalid server
/// payloads instead of constructing partially-correct objects.
library;

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

class BudgetJson {
  BudgetJson._();

  /// Throws if [fieldName] is missing or null in [json].
  static void requireField(Map<String, dynamic> json, String fieldName) {
    if (!json.containsKey(fieldName) || json[fieldName] == null) {
      throw ArgumentError.value(
        json,
        'json',
        'Missing or null required field: $fieldName',
      );
    }
  }

  /// Returns a non-empty string at [fieldName] in [json], else throws.
  static String requireString(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];
    if (value is! String) {
      throw ArgumentError.value(value, fieldName, 'must be a string');
    }
    if (value.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'must not be empty');
    }
    return value;
  }

  /// Returns a strictly positive `double` at `limit_amount`.
  ///
  /// Server may send int or double; we coerce via [num.toDouble].
  static double requirePositiveLimit(Map<String, dynamic> json) {
    final value = json['limit_amount'];
    if (value is! num) {
      throw ArgumentError.value(value, 'limit_amount', 'must be a number');
    }
    final limitAmount = value.toDouble();
    if (limitAmount <= 0) {
      throw ArgumentError.value(
        limitAmount,
        'limit_amount',
        'must be positive',
      );
    }
    return limitAmount;
  }

  /// Returns the [TransactionCategory] at `category`, accepting any casing.
  static TransactionCategory requireCategory(Map<String, dynamic> json) {
    return TransactionCategory.fromName(requireString(json, 'category'));
  }

  /// Returns the [BudgetPeriod] at `period`, accepting any casing.
  static BudgetPeriod requirePeriod(Map<String, dynamic> json) {
    return BudgetPeriod.fromName(requireString(json, 'period'));
  }

  /// Parses an ISO-8601 date string at [fieldName].
  ///
  /// Wraps [FormatException] in [ArgumentError] so callers get a uniform error
  /// type whether the field is missing, wrong type, or unparseable.
  static DateTime requireDateTime(Map<String, dynamic> json, String fieldName) {
    final dateString = requireString(json, fieldName);
    try {
      return DateTime.parse(dateString);
    } on FormatException catch (e) {
      throw ArgumentError.value(
        dateString,
        fieldName,
        'Invalid date format: ${e.message}',
      );
    }
  }
}
