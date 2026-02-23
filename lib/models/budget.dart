/// A spending limit for a specific category over a time period.
class Budget {
  final String id;
  final String userId;
  final String category;
  final double limitAmount;
  final String period; // e.g. 'monthly', 'weekly'
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.createdAt,
  });

  /// Deserialize from JSON (snake_case keys from the API).
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

  /// Serialize to a JSON-compatible map.
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

  /// Create a copy with selectively overridden fields.
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
}
