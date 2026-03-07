/// Card for one savings goal: description, progress/target, progress bar, target date, optional "Done" chip.
///
/// Used on [GoalsScreen]. Optional [onTap] for edit/detail.
/// When [icon] is omitted, defaults to the [GoalCategoryUi] icon for [Goal.category].
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/goal_helpers.dart';

/// Goal card with header, progress text, bar, and target date; shows "Done" when [Goal.isCompleted].
class GoalProgressCard extends StatelessWidget {
  /// The goal to display (description, progress, targetAmount, targetDate).
  final Goal goal;

  /// Icon for the goal; defaults to the [GoalCategoryUi] icon for [Goal.category].
  final IconData icon;

  /// Optional tap handler (e.g. open edit or add funds).
  final VoidCallback? onTap;

  GoalProgressCard({super.key, required this.goal, IconData? icon, this.onTap})
    : icon = icon ?? goal.category.icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = goal.progressPercent.clamp(0.0, 1.0);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(goal: goal, icon: icon),
              const SizedBox(height: AppSpacing.s12),
              _ProgressRow(goal: goal, percent: percent),
              const SizedBox(height: AppSpacing.s6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: AppSpacing.sm,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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

/// Private row: goal icon, description, and "Done" chip when completed.
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
        const SizedBox(width: AppSpacing.sm),
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

/// Private row: "progress of target" currency and percent label.
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
