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

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      limitAmount: (json['limit_amount'] as num).toDouble(),
      period: json['period'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'limit_amount': limitAmount,
      'period': period,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
