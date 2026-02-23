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
}
