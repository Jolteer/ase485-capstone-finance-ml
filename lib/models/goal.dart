/// Data model representing a user’s financial savings goal.
///
/// Maps to the `Goal` table in PostgreSQL:
/// - [id]           – unique identifier.
/// - [userId]       – foreign key linking to the owning User.
/// - [targetAmount] – dollar amount the user wants to save.
/// - [targetDate]   – deadline the user is aiming for.
/// - [description]  – short description (e.g. “Save for vacation”).
/// - [progress]     – how many dollars the user has saved toward this goal so far.
///
/// Computed properties:
/// - [progressPercent] – progress as a 0.0–1.0 fraction (clamped).
/// - [isCompleted]     – whether the user has reached the target.
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

  /// Fraction of the goal completed, clamped between 0.0 and 1.0.
  /// Returns 0 if [targetAmount] is zero to avoid division-by-zero.
  double get progressPercent =>
      targetAmount > 0 ? (progress / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Whether the user has saved enough to meet (or exceed) the target.
  bool get isCompleted => progress >= targetAmount;

  /// Deserialise a [Goal] from a JSON map returned by the API.
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

  /// Serialise this [Goal] to a JSON map for API requests.
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

  /// Return a copy with selected fields replaced.
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
