/// Represents a savings goal with a target amount and deadline.
/// 
/// Goals help users save toward specific objectives by tracking progress
/// toward a [targetAmount] by a given [targetDate].
class Goal {
  /// Unique identifier for the goal.
  final String id;
  
  /// ID of the user who owns this goal.
  final String userId;
  
  /// Target amount of money to save for this goal.
  final double targetAmount;
  
  /// Deadline by which the goal should be achieved.
  final DateTime targetDate;
  
  /// Descriptive text explaining what this goal is for.
  final String description;
  
  /// Current progress toward the goal (amount saved so far).
  final double progress;

  /// Creates a new [Goal] instance.
  const Goal({
    required this.id,
    required this.userId,
    required this.targetAmount,
    required this.targetDate,
    required this.description,
    required this.progress,
  });

  /// Calculates the progress as a percentage (0.0 to 1.0) of the target amount.
  /// 
  /// Returns 0 if [targetAmount] is 0 or negative.
  double get progressPercent => targetAmount > 0 ? progress / targetAmount : 0;

  /// Returns true if the goal has been fully achieved.
  /// 
  /// A goal is considered completed when [progress] meets or exceeds [targetAmount].
  bool get isCompleted => progress >= targetAmount;

  /// Creates a [Goal] instance from a JSON map.
  /// 
  /// Expects keys: 'id', 'user_id', 'target_amount', 'target_date', 'description', and 'progress'.
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

  /// Converts this [Goal] instance to a JSON map.
  /// 
  /// Returns a map with keys: 'id', 'user_id', 'target_amount', 'target_date', 'description', and 'progress'.
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

  /// Creates a copy of this [Goal] with the given fields replaced.
  /// 
  /// Any field left as null will retain its current value.
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
