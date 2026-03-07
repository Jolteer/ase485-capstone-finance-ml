/// Domain model for a category budget over a time period (e.g. monthly).
///
/// Supports JSON via [fromJson] / [toJson], immutability via [copyWith],
/// and value equality. Use with budget management and spending limits.
/// Use [BudgetPeriod] for type-safe period access and [TransactionCategory]
/// for type-safe category access.
library;

import 'package:ase485_capstone_finance_ml/models/transaction.dart';

// ============================================================================
// Enums and Constants
// ============================================================================

/// Type-safe budget recurrence period.
///
/// Each value carries a [displayLabel] for UI presentation.
enum BudgetPeriod {
  weekly('Weekly'),
  biweekly('Bi-weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const BudgetPeriod(this.displayLabel);

  /// Human-readable label for this period.
  final String displayLabel;

  /// Parses a [BudgetPeriod] from its [name] string; falls back to [monthly].
  ///
  /// Parameters:
  ///   [name] - The period name string to parse (case-insensitive)
  ///
  /// Returns the matching [BudgetPeriod] or [monthly] as default.
  static BudgetPeriod fromName(String name) {
    return BudgetPeriod.values.firstWhere(
      (p) => p.name == name.toLowerCase(),
      orElse: () => BudgetPeriod.monthly,
    );
  }
}

// ============================================================================
// Budget Model
// ============================================================================

/// Represents a spending limit for a category over a time period.
///
/// Immutable value object with validation ensuring data integrity.
class Budget {
  /// Unique identifier for this budget.
  final String id;

  /// ID of the user this budget belongs to.
  final String userId;

  /// Category this budget applies to.
  final TransactionCategory category;

  /// Maximum amount allowed to spend in this category for the period.
  final double limitAmount;

  /// Recurrence period this budget covers.
  final BudgetPeriod period;

  /// When this budget was created.
  final DateTime createdAt;

  /// Creates a new [Budget] instance.
  ///
  /// Parameters:
  ///   [id] - Unique budget identifier (must not be empty)
  ///   [userId] - User identifier (must not be empty)
  ///   [category] - Transaction category for this budget
  ///   [limitAmount] - Maximum spending limit (must be positive)
  ///   [period] - Time period for budget recurrence
  ///   [createdAt] - Budget creation timestamp
  ///
  /// Throws [AssertionError] if [limitAmount] is not positive.
  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  }) : assert(id != '', 'id must not be empty'),
       assert(userId != '', 'userId must not be empty'),
       assert(limitAmount > 0, 'limitAmount must be positive');

  // ==========================================================================
  // Public Methods
  // ==========================================================================

  /// Creates a [Budget] from a JSON map (e.g. API response).
  ///
  /// Parameters:
  ///   [json] - Map containing budget data with snake_case keys
  ///
  /// Returns a new [Budget] instance.
  ///
  /// Throws:
  ///   [ArgumentError] if any required field is missing, null, or invalid
  ///   [FormatException] if date string cannot be parsed
  factory Budget.fromJson(Map<String, dynamic> json) {
    _validateJsonNotNull(json, 'id');
    _validateJsonNotNull(json, 'user_id');
    _validateJsonNotNull(json, 'category');
    _validateJsonNotNull(json, 'limit_amount');
    _validateJsonNotNull(json, 'period');
    _validateJsonNotNull(json, 'created_at');

    final id = _extractStringField(json, 'id');
    final userId = _extractStringField(json, 'user_id');
    final limitAmount = _extractAndValidateLimitAmount(json);
    final category = _extractCategory(json);
    final period = _extractPeriod(json);
    final createdAt = _extractDateTime(json, 'created_at');

    return Budget(
      id: id,
      userId: userId,
      category: category,
      limitAmount: limitAmount,
      period: period,
      createdAt: createdAt,
    );
  }

  /// Converts this budget to a JSON map (snake_case keys for API).
  ///
  /// Returns a map suitable for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.name,
      'limit_amount': limitAmount,
      'period': period.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Returns a copy of this budget with the given fields replaced.
  ///
  /// Parameters:
  ///   [id] - New budget ID (optional)
  ///   [userId] - New user ID (optional)
  ///   [category] - New category (optional)
  ///   [limitAmount] - New limit amount (optional, must be positive if provided)
  ///   [period] - New period (optional)
  ///   [createdAt] - New creation date (optional)
  ///
  /// Returns a new [Budget] instance with updated fields.
  ///
  /// Throws [ArgumentError] if [limitAmount] is provided and not positive.
  Budget copyWith({
    String? id,
    String? userId,
    TransactionCategory? category,
    double? limitAmount,
    BudgetPeriod? period,
    DateTime? createdAt,
  }) {
    if (limitAmount != null && limitAmount <= 0) {
      throw ArgumentError.value(limitAmount, 'limitAmount', 'must be positive');
    }

    if (id != null && id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }

    if (userId != null && userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must not be empty');
    }

    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          category == other.category &&
          limitAmount == other.limitAmount &&
          period == other.period &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, userId, category, limitAmount, period, createdAt);

  @override
  String toString() =>
      'Budget(id: $id, category: ${category.name}, '
      'limit: $limitAmount, period: ${period.name})';

  // ==========================================================================
  // Private Helper Methods
  // ==========================================================================

  /// Validates that a JSON field exists and is not null.
  ///
  /// Parameters:
  ///   [json] - The JSON map to validate
  ///   [fieldName] - The field name to check
  ///
  /// Throws [ArgumentError] if field is missing or null.
  static void _validateJsonNotNull(
    Map<String, dynamic> json,
    String fieldName,
  ) {
    if (!json.containsKey(fieldName) || json[fieldName] == null) {
      throw ArgumentError.value(
        json,
        'json',
        'Missing or null required field: $fieldName',
      );
    }
  }

  /// Extracts and validates a string field from JSON.
  ///
  /// Parameters:
  ///   [json] - The JSON map
  ///   [fieldName] - The field name to extract
  ///
  /// Returns the non-empty string value.
  ///
  /// Throws [ArgumentError] if field is not a string or is empty.
  static String _extractStringField(
    Map<String, dynamic> json,
    String fieldName,
  ) {
    final value = json[fieldName];

    if (value is! String) {
      throw ArgumentError.value(value, fieldName, 'must be a string');
    }

    if (value.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'must not be empty');
    }

    return value;
  }

  /// Extracts and validates the limit amount from JSON.
  ///
  /// Parameters:
  ///   [json] - The JSON map containing limit_amount
  ///
  /// Returns the validated positive limit amount.
  ///
  /// Throws [ArgumentError] if limit_amount is not a number or not positive.
  static double _extractAndValidateLimitAmount(Map<String, dynamic> json) {
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

  /// Extracts the category from JSON.
  ///
  /// Parameters:
  ///   [json] - The JSON map containing category
  ///
  /// Returns the parsed [TransactionCategory].
  ///
  /// Throws [ArgumentError] if category is not a string.
  static TransactionCategory _extractCategory(Map<String, dynamic> json) {
    final categoryString = _extractStringField(json, 'category');
    return TransactionCategory.fromName(categoryString);
  }

  /// Extracts the period from JSON.
  ///
  /// Parameters:
  ///   [json] - The JSON map containing period
  ///
  /// Returns the parsed [BudgetPeriod].
  ///
  /// Throws [ArgumentError] if period is not a string.
  static BudgetPeriod _extractPeriod(Map<String, dynamic> json) {
    final periodString = _extractStringField(json, 'period');
    return BudgetPeriod.fromName(periodString);
  }

  /// Extracts and parses a DateTime field from JSON.
  ///
  /// Parameters:
  ///   [json] - The JSON map
  ///   [fieldName] - The field name containing the ISO8601 date string
  ///
  /// Returns the parsed [DateTime].
  ///
  /// Throws:
  ///   [ArgumentError] if field is not a string
  ///   [FormatException] if date string is invalid
  static DateTime _extractDateTime(
    Map<String, dynamic> json,
    String fieldName,
  ) {
    final dateString = _extractStringField(json, fieldName);

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
