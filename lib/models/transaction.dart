/// A single financial transaction (income or expense).
///
/// [amount] is positive for income, negative for expense. Supports JSON via
/// [fromJson] / [toJson] and [copyWith]. Used for lists, analytics, and budgets.
class Transaction {
  /// Unique identifier for this transaction.
  final String id;

  /// ID of the user this transaction belongs to.
  final String userId;

  /// Amount; positive = income, negative = expense.
  final double amount;

  /// Category (e.g. "Groceries", "Salary").
  final String category;

  /// Description or memo for the transaction.
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
  });

  /// Creates a [Transaction] from a JSON map (e.g. API response).
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Converts this transaction to a JSON map (snake_case keys for API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  /// Returns a copy of this transaction with the given fields replaced.
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
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
      'Transaction(id: $id, amount: $amount, category: $category, description: $description)';
}
