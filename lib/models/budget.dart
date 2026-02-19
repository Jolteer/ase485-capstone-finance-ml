class Budget {
  final String id;
  final String userId;
  final String category;
  final double limitAmount;
  final String period;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  });
}
