/// Represents a financial goal set by the user.
class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  bool get isComplete => currentAmount >= targetAmount;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }
}
