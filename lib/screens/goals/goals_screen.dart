import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._sampleGoals.map(
            (g) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(g.icon, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            g.description,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (g.progress >= g.target)
                          Chip(
                            label: const Text('Done'),
                            backgroundColor: Colors.green.withAlpha(40),
                            labelStyle: const TextStyle(color: Colors.green),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${g.progress.toStringAsFixed(0)} of \$${g.target.toStringAsFixed(0)}',
                        ),
                        Text(
                          '${(g.progress / g.target * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (g.progress / g.target).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${g.targetDate}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}

class _GoalItem {
  final IconData icon;
  final String description;
  final double progress;
  final double target;
  final String targetDate;
  const _GoalItem(
    this.icon,
    this.description,
    this.progress,
    this.target,
    this.targetDate,
  );
}

const _sampleGoals = [
  _GoalItem(Icons.beach_access, 'Vacation Fund', 1800, 3000, 'Jun 2026'),
  _GoalItem(Icons.home, 'Down Payment', 12000, 50000, 'Dec 2027'),
  _GoalItem(Icons.warning_amber, 'Emergency Fund', 5000, 5000, 'Jan 2026'),
  _GoalItem(Icons.directions_car, 'New Car', 3200, 15000, 'Mar 2027'),
];
