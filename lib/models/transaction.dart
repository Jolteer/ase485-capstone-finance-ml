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
}
