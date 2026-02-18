/// Data model representing a single spending or income entry.
///
/// Maps to the `Transaction` table in PostgreSQL:
/// - [id]          – unique identifier.
/// - [userId]      – foreign key linking to the owning User.
/// - [amount]      – dollar value (positive = income, negative = expense).
/// - [category]    – spending category assigned by the ML model or user.
/// - [description] – free-text note (e.g. “Lunch at Chipotle”).
/// - [date]        – when the transaction occurred.
///
/// Provides [fromJson] / [toJson] for API serialisation and [copyWith]
/// for immutable updates.
class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  /// Build a [Transaction] from a JSON map (snake_case keys).
  /// [amount] is cast via `num` so both int and double JSON values work.
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

  /// Convert this [Transaction] back to a JSON map for API requests.
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

  /// Create a copy of this [Transaction] with selected fields overridden.
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
}
