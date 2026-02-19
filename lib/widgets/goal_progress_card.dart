import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  final String description;
  final double progress;
  final double target;
  final DateTime targetDate;

  const GoalProgressCard({
    super.key,
    required this.description,
    required this.progress,
    required this.target,
    required this.targetDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(description),
      ),
    );
  }
}
