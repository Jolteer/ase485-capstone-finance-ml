/// A savings goal the user is working toward.
class Goal {
  final String id;
  final String userId;
  final double targetAmount;
  final DateTime targetDate;
  final String description;
  final double progress; // amount saved so far

  const Goal({
    required this.id,
    required this.userId,
    required this.targetAmount,
    required this.targetDate,
    required this.description,
    required this.progress,
  });

  /// Fraction of target achieved (0.0 – 1.0+).
  double get progressPercent => targetAmount == 0 ? 0 : progress / targetAmount;

  /// Whether the goal has been fully reached.
  bool get isCompleted => progress >= targetAmount;

  /// Deserialize from JSON (snake_case keys from the API).
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      targetDate: DateTime.parse(json['target_date'] as String),
      description: json['description'] as String,
      progress: (json['progress'] as num).toDouble(),
    );
  }

  /// Serialize to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_amount': targetAmount,
      'target_date': targetDate.toIso8601String(),
      'description': description,
      'progress': progress,
    };
  }

  /// Create a copy with selectively overridden fields.
  Goal copyWith({
    String? id,
    String? userId,
    double? targetAmount,
    DateTime? targetDate,
    String? description,
    double? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      progress: progress ?? this.progress,
    );
  }
}
