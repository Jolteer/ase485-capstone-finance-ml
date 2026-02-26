/// A savings goal with a [targetAmount] and deadline ([targetDate]).
class Goal {
  final String id;
  final String userId;
  final double targetAmount;
  final DateTime targetDate;
  final String description;
  final double progress;

  const Goal({
    required this.id,
    required this.userId,
    required this.targetAmount,
    required this.targetDate,
    required this.description,
    required this.progress,
  });

  double get progressPercent => targetAmount > 0 ? progress / targetAmount : 0;

  bool get isCompleted => progress >= targetAmount;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          targetAmount == other.targetAmount &&
          targetDate == other.targetDate &&
          description == other.description &&
          progress == other.progress;

  @override
  int get hashCode =>
      Object.hash(id, userId, targetAmount, targetDate, description, progress);

  @override
  String toString() =>
      'Goal(id: $id, description: $description, progress: $progress/$targetAmount)';
}
