/// Represents a single financial transaction.
/// 
/// A transaction can be either income (positive amount) or expense (negative amount).
/// Each transaction is categorized and includes a description and date.
class Transaction {
  /// Unique identifier for the transaction.
  final String id;
  
  /// ID of the user who owns this transaction.
  final String userId;
  
  /// Transaction amount (positive for income, negative for expense).
  final double amount;
  
  /// Category of the transaction (e.g., 'Food', 'Salary', 'Entertainment').
  final String category;
  
  /// Descriptive text explaining the transaction.
  final String description;
  
  /// Date when the transaction occurred.
  final DateTime date;

  /// Creates a new [Transaction] instance.
  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  /// Creates a [Transaction] instance from a JSON map.
  /// 
  /// Expects keys: 'id', 'user_id', 'amount', 'category', 'description', and 'date'.
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

  /// Converts this [Transaction] instance to a JSON map.
  /// 
  /// Returns a map with keys: 'id', 'user_id', 'amount', 'category', 'description', and 'date'.
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

  /// Creates a copy of this [Transaction] with the given fields replaced.
  /// 
  /// Any field left as null will retain its current value.
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
