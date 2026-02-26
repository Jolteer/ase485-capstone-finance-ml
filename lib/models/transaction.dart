/// A single financial transaction (positive = income, negative = expense).
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
