/// A spending budget for a given [category] over a [period] (e.g. 'monthly').
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

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? limitAmount,
    String? period,
    DateTime? createdAt,
  }) {
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
      'Budget(id: $id, category: $category, limit: $limitAmount, period: $period)';
}
