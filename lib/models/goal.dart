/// Domain model for a user savings goal with target amount and date.
///
/// Supports JSON via [fromJson] / [toJson], [copyWith], and [icon] for UI.
/// Use [progressPercent] and [isCompleted] for progress display.
import 'package:flutter/material.dart';

class Goal {
  /// Unique identifier for this goal.
  final String id;

  /// ID of the user who owns this goal.
  final String userId;

  /// Target amount to save.
  final double targetAmount;

  /// Date by which the goal should be reached.
  final DateTime targetDate;

  /// Short description of the goal (e.g. "Vacation", "Emergency fund").
  final String description;

  /// Current amount saved toward the goal.
  final double progress;

  const Goal({
    required this.id,
    required this.userId,
    required this.targetAmount,
    required this.targetDate,
    required this.description,
    required this.progress,
  });

  /// Fraction of goal completed (0.0–1.0+); 0 if target is zero.
  double get progressPercent => targetAmount > 0 ? progress / targetAmount : 0;

  /// True when [progress] meets or exceeds [targetAmount].
  bool get isCompleted => progress >= targetAmount;

  /// Creates a [Goal] from a JSON map (e.g. API response).
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

  /// Converts this goal to a JSON map (snake_case keys for API).
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

  /// Returns a copy of this goal with the given fields replaced.
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

  /// Icon for this goal based on [description] (e.g. vacation → beach, home → home).
  IconData get icon {
    final desc = description.toLowerCase();
    if (desc.contains('vacation')) return Icons.beach_access;
    if (desc.contains('down payment') || desc.contains('home')) {
      return Icons.home;
    }
    if (desc.contains('emergency')) return Icons.warning_amber;
    if (desc.contains('car')) return Icons.directions_car;
    return Icons.flag;
  }
}
