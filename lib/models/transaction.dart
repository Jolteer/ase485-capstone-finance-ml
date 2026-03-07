/// A single financial transaction (income or expense).
///
/// [amount] is positive for income, negative for expense.
/// Use [isExpense], [isIncome], and [absAmount] for display logic rather than
/// inspecting [amount] directly at the call site.
/// Supports JSON via [fromJson] / [toJson] and [copyWith].
/// For UI icons and colors import lib/utils/categories.dart for the
/// [TransactionCategoryUi] extension.
library;

/// Type-safe category for a [Transaction].
///
/// Each value owns its [label]. Icon and color live in the UI layer —
/// import [TransactionCategoryUi] from lib/utils/categories.dart when you need them.
enum TransactionCategory {
  food('Food'),
  entertainment('Entertainment'),
  bills('Bills'),
  shopping('Shopping'),
  transportation('Transportation'),
  healthcare('Healthcare'),
  education('Education'),
  other('Other');

  const TransactionCategory(this.label);

  /// Human-readable label for this category.
  final String label;

  /// Parses a [TransactionCategory] from a string; falls back to [other].
  ///
  /// Matches against the enum [name] (e.g. `"food"`) or [label] (e.g. `"Food"`)
  /// case-insensitively, so both serialized enum names and legacy capitalized
  /// strings resolve correctly.
  static TransactionCategory fromName(String name) {
    final lower = name.toLowerCase();
    return TransactionCategory.values.firstWhere(
      (c) => c.name == lower || c.label.toLowerCase() == lower,
      orElse: () => TransactionCategory.other,
    );
  }
}

class Transaction {
  /// Unique identifier for this transaction.
  final String id;

  /// ID of the user this transaction belongs to.
  final String userId;

  /// Amount; positive = income, negative = expense.
  final double amount;

  /// Category of this transaction.
  final TransactionCategory category;

  /// Description or memo for the transaction. Must not be empty.
  final String description;

  /// Date and time when the transaction occurred.
  final DateTime date;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  }) : assert(amount != 0, 'amount must not be zero'),
       assert(description != '', 'description must not be empty');

  /// True when [amount] is negative (an expense).
  bool get isExpense => amount < 0;

  /// True when [amount] is positive (income).
  bool get isIncome => amount > 0;

  /// Absolute value of [amount]; useful for display without a leading minus sign.
  double get absAmount => amount.abs();

  /// Creates a [Transaction] from a JSON map (e.g. API response).
  ///
  /// Throws [ArgumentError] for invalid field values so bad API data is caught
  /// in both debug and release builds.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    final description = json['description'] as String;

    if (amount == 0) {
      throw ArgumentError.value(amount, 'amount', 'must not be zero');
    }
    if (description.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'must not be empty',
      );
    }

    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: amount,
      category: TransactionCategory.fromName(
        (json['category'] as String?) ?? TransactionCategory.other.name,
      ),
      description: description,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Converts this transaction to a JSON map (snake_case keys for API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category.name,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  /// Returns a copy of this transaction with the given fields replaced.
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionCategory? category,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          amount == other.amount &&
          category == other.category &&
          description == other.description &&
          date == other.date;

  @override
  int get hashCode =>
      Object.hash(id, userId, amount, category, description, date);

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, category: ${category.name}, '
      'description: $description)';
}
