/// Represents a spending budget for a specific category over a defined period.
/// 
/// Budgets help users track and limit their spending in various categories
/// (e.g., 'Food', 'Entertainment') over periods like 'monthly' or 'weekly'.
class Budget {
  /// Unique identifier for the budget.
  final String id;
  
  /// ID of the user who owns this budget.
  final String userId;
  
  /// Spending category this budget applies to (e.g., 'Food', 'Transport').
  final String category;
  
  /// Maximum allowed spending amount for this category in the given period.
  final double limitAmount;
  
  /// Time period for the budget (e.g., 'monthly', 'weekly', 'yearly').
  final String period;
  
  /// Timestamp when this budget was created.
  final DateTime createdAt;

  /// Creates a new [Budget] instance.
  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  });

  /// Creates a [Budget] instance from a JSON map.
  /// 
  /// Expects keys: 'id', 'user_id', 'category', 'limit_amount', 'period', and 'created_at'.
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

  /// Converts this [Budget] instance to a JSON map.
  /// 
  /// Returns a map with keys: 'id', 'user_id', 'category', 'limit_amount', 'period', and 'created_at'.
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

  /// Creates a copy of this [Budget] with the given fields replaced.
  /// 
  /// Any field left as null will retain its current value.
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
