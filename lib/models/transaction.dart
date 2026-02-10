/// Represents a single spending transaction.
class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };
}
