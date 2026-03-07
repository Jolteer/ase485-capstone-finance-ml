/// Domain model for a user savings goal with target amount and date.
///
/// Supports JSON via [fromJson] / [toJson], [copyWith].
/// Use [progressPercent], [remainingAmount], [daysRemaining], and [isCompleted]
/// for progress display. Use [GoalCategory] for type-safe label access.
/// For UI icons import lib/utils/goal_helpers.dart for the [GoalCategoryUi] extension.
library;

/// Type-safe category for a savings goal.
///
/// Each value carries a [label] for display. Icon data lives in the UI layer —
/// import [GoalCategoryUi] from lib/utils/goal_helpers.dart when you need icons.
enum GoalCategory {
  vacation('Vacation'),
  home('Home'),
  emergency('Emergency'),
  car('Car'),
  other('Other');

  const GoalCategory(this.label);

  /// Human-readable label for this category.
  final String label;

  /// Parses a [GoalCategory] from its [name] string; falls back to [other].
  static GoalCategory fromName(String name) {
    return GoalCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => GoalCategory.other,
    );
  }
}

class Goal {
  /// Unique identifier for this goal.
  final String id;

  /// ID of the user who owns this goal.
  final String userId;

  /// Target amount to save. Must be non-negative.
  final double targetAmount;

  /// Date by which the goal should be reached.
  final DateTime targetDate;

  /// Short description of the goal (e.g. "Vacation", "Emergency fund").
  /// Must not be empty.
  final String description;

  /// Current amount saved toward the goal. Must be non-negative.
  final double progress;

  /// Category determining the display icon and label for this goal.
  final GoalCategory category;

  const Goal({
    required this.id,
    required this.userId,
    required this.targetAmount,
    required this.targetDate,
    required this.description,
    required this.progress,
    required this.category,
  }) : assert(targetAmount >= 0, 'targetAmount must be non-negative'),
       assert(progress >= 0, 'progress must be non-negative'),
       assert(description != '', 'description must not be empty');

  /// Fraction of goal completed (0.0–1.0+); 0 if [targetAmount] is zero.
  ///
  /// May exceed 1.0 when [progress] surpasses [targetAmount]. Clamp at the
  /// call site when a bounded value is required (e.g. a progress indicator).
  double get progressPercent => targetAmount > 0 ? progress / targetAmount : 0;

  /// True when [progress] meets or exceeds [targetAmount].
  bool get isCompleted => progress >= targetAmount;

  /// Amount still needed to reach [targetAmount]; 0 when already completed.
  double get remainingAmount =>
      (targetAmount - progress).clamp(0.0, double.maxFinite);

  /// Whole days remaining until [targetDate] from today; 0 if past due.
  int get daysRemaining =>
      targetDate.difference(DateTime.now()).inDays.clamp(0, 999999);

  /// Creates a [Goal] from a JSON map (e.g. API response).
  ///
  /// Throws [ArgumentError] for invalid field values so bad API data is caught
  /// in both debug and release builds.
  factory Goal.fromJson(Map<String, dynamic> json) {
    final targetAmount = (json['target_amount'] as num).toDouble();
    final progress = (json['progress'] as num).toDouble();
    final description = json['description'] as String;

    if (targetAmount < 0) {
      throw ArgumentError.value(
        targetAmount,
        'target_amount',
        'must be non-negative',
      );
    }
    if (progress < 0) {
      throw ArgumentError.value(progress, 'progress', 'must be non-negative');
    }
    if (description.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'must not be empty',
      );
    }

    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetAmount: targetAmount,
      targetDate: DateTime.parse(json['target_date'] as String),
      description: description,
      progress: progress,
      category: GoalCategory.fromName(
        (json['category'] as String?) ?? GoalCategory.other.name,
      ),
    );
  }

  /// Converts this goal to a JSON map (snake_case keys for API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_amount': targetAmount,
      'target_date': targetDate.toIso8601String(),
      'description': description,
      'progress': progress,
      'category': category.name,
    };
  }

  /// Returns a copy of this goal with the given fields replaced.
  Goal copyWith({
    String? id,
    String? userId,
    double? targetAmount,
    DateTime? targetDate,
    String? description,
    double? progress,
    GoalCategory? category,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      category: category ?? this.category,
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
          progress == other.progress &&
          category == other.category;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    targetAmount,
    targetDate,
    description,
    progress,
    category,
  );

  @override
  String toString() =>
      'Goal(id: $id, description: $description, category: ${category.name}, '
      'progress: $progress/$targetAmount)';
}
