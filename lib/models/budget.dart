/// Domain model for a category budget over a time period (e.g. monthly).
///
/// Supports JSON via [Budget.fromJson] / [toJson], immutability via
/// [copyWith], and value equality. JSON validation is delegated to
/// [BudgetJson] in `_budget_json.dart` to keep this file focused on the
/// value type itself.
library;

import 'package:ase485_capstone_finance_ml/models/_budget_json.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

/// Type-safe budget recurrence period, with a UI label per value.
enum BudgetPeriod {
  weekly('Weekly'),
  biweekly('Bi-weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const BudgetPeriod(this.displayLabel);

  /// Human-readable label for this period.
  final String displayLabel;

  /// Parses a [BudgetPeriod] from its enum [name] (case-insensitive); falls
  /// back to [monthly] so unexpected server values don't crash the UI.
  static BudgetPeriod fromName(String name) {
    return BudgetPeriod.values.firstWhere(
      (p) => p.name == name.toLowerCase(),
      orElse: () => BudgetPeriod.monthly,
    );
  }
}

/// Spending limit for a category over a time period.
///
/// Immutable value object; constructor asserts non-empty IDs and a positive
/// [limitAmount] so invalid budgets cannot be constructed in app code.
class Budget {
  /// Unique identifier for this budget.
  final String id;

  /// Owning user's ID.
  final String userId;

  /// Category this budget applies to.
  final TransactionCategory category;

  /// Maximum spend allowed for the period.
  final double limitAmount;

  /// Recurrence period this budget covers.
  final BudgetPeriod period;

  /// When this budget was created.
  final DateTime createdAt;

  /// Throws [AssertionError] if [limitAmount] is not positive.
  ///
  /// [id] and [userId] are intentionally allowed to be empty so the UI can
  /// construct a "not yet persisted" budget before POST /budgets assigns the
  /// server-side identifiers. Server responses are validated separately by
  /// [Budget.fromJson] via [BudgetJson.requireString].
  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  }) : assert(limitAmount > 0, 'limitAmount must be positive');

  /// Builds a [Budget] from a server JSON payload (snake_case keys).
  ///
  /// Throws [ArgumentError] (and uses it to wrap [FormatException]) on any
  /// missing, null, or malformed field — see [BudgetJson] for details.
  factory Budget.fromJson(Map<String, dynamic> json) {
    BudgetJson.requireField(json, 'id');
    BudgetJson.requireField(json, 'user_id');
    BudgetJson.requireField(json, 'category');
    BudgetJson.requireField(json, 'limit_amount');
    BudgetJson.requireField(json, 'period');
    BudgetJson.requireField(json, 'created_at');

    return Budget(
      id: BudgetJson.requireString(json, 'id'),
      userId: BudgetJson.requireString(json, 'user_id'),
      category: BudgetJson.requireCategory(json),
      limitAmount: BudgetJson.requirePositiveLimit(json),
      period: BudgetJson.requirePeriod(json),
      createdAt: BudgetJson.requireDateTime(json, 'created_at'),
    );
  }

  /// Serializes this budget to snake_case JSON suitable for the API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'category': category.name,
    'limit_amount': limitAmount,
    'period': period.name,
    'created_at': createdAt.toIso8601String(),
  };

  /// Returns a copy with selected fields replaced.
  ///
  /// Re-validates [limitAmount] so `copyWith` can't produce a value that the
  /// constructor would reject; throws [ArgumentError] (instead of asserting)
  /// so this fails in release builds too. [id] and [userId] are not checked
  /// here because the model intentionally permits empty values for the
  /// not-yet-persisted case (see the constructor doc comment).
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
}
