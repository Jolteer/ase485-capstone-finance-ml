import 'package:flutter/material.dart';

/// A card that shows how close a user is to reaching a savings goal.
///
/// Displays:
/// • The goal description as a title.
/// • A [LinearProgressIndicator] showing [progress] / [target].
/// • A label like `$500.00 of $2,000.00  •  25%`.
///
/// [percent] is clamped to 0–1 so the bar never visually overflows.
class GoalProgressCard extends StatelessWidget {
  /// Human-readable goal description (e.g. “Vacation Fund”).
  final String description;

  /// Current dollar amount saved so far.
  final double progress;

  /// Target dollar amount for the goal.
  final double target;

  /// Date by which the user wants to reach the goal.
  final DateTime targetDate;

  const GoalProgressCard({
    super.key,
    required this.description,
    required this.progress,
    required this.target,
    required this.targetDate,
  });

  /// The completion ratio (0–1) used by the progress indicator.
  double get percent => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal description header.
            Text(description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Visual progress bar.
            LinearProgressIndicator(value: percent),
            const SizedBox(height: 4),
            // Dollar progress and percentage label.
            Text(
              '\$${progress.toStringAsFixed(2)} of \$${target.toStringAsFixed(2)}  •  ${(percent * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }
}
