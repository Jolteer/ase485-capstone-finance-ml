/// Domain model for a category budget over a time period (e.g. monthly).
///
/// Supports JSON via [fromJson] / [toJson], immutability via [copyWith],
/// and value equality. Use with budget management and spending limits.
class Budget {
  /// Unique identifier for this budget.
  final String id;

  /// ID of the user this budget belongs to.
  final String userId;

  /// Budget category (e.g. "Groceries", "Entertainment").
  final String category;

  /// Maximum amount allowed to spend in this category for the period.
  final double limitAmount;

  /// Period this budget covers (e.g. "monthly", "weekly").
  final String period;

  /// When this budget was created.
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  });

  /// Creates a [Budget] from a JSON map (e.g. API response).
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

  /// Converts this budget to a JSON map (snake_case keys for API).
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

  /// Returns a copy of this budget with the given fields replaced.
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
