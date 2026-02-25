import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class GoalProgressCard extends StatelessWidget {
  final Goal goal;
  final IconData icon;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = goal.progressPercent.clamp(0.0, 1.0);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(goal: goal, icon: icon),
              const SizedBox(height: 12),
              _ProgressRow(goal: goal, percent: percent),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${Formatters.date(goal.targetDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.goal, required this.icon});

  final Goal goal;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            goal.description,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (goal.isCompleted)
          Chip(
            label: const Text('Done'),
            backgroundColor: theme.colorScheme.primaryContainer,
            labelStyle: TextStyle(color: theme.colorScheme.primary),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.goal, required this.percent});

  final Goal goal;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${Formatters.currency(goal.progress)} of '
          '${Formatters.currency(goal.targetAmount)}',
        ),
        Text(Formatters.percent(percent), style: theme.textTheme.labelLarge),
      ],
    );
  }
}
