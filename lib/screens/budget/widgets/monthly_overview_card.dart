/// Monthly summary card for the Budget tab: total spent vs total budget.
///
/// Pure visual; consumers compute the totals themselves and pass them in,
/// keeping this widget testable without provider scaffolding.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class MonthlyOverviewCard extends StatelessWidget {
  /// Month being summarised; only the year+month matter for the heading.
  final DateTime month;

  /// Total spent this month across every tracked budget.
  final double spent;

  /// Sum of every budget's [Budget.limitAmount] for the month.
  final double budget;

  const MonthlyOverviewCard({
    super.key,
    required this.month,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Clamp the ratio so the progress bar tops out at 100% even when the
    // user has overspent; we still surface the overage in the percent label.
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              DateFormat.yMMMM().format(month),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${Formatters.currency(spent)} / ${Formatters.currency(budget)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: AppSpacing.s10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}% of monthly budget used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
