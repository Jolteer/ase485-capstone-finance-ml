/// Card showing total spend for the last 3 calendar months.
///
/// The current month is highlighted in the primary colour so the user can see
/// the trend at a glance.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';

class MonthComparisonCard extends StatelessWidget {
  /// One entry per month, ordered oldest to newest.
  final List<MonthSpending> months;

  const MonthComparisonCard({super.key, required this.months});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month over Month', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: months
                  .map(
                    (m) => _MonthStat(
                      month: m.label,
                      amount: m.amount,
                      isCurrent: m.isCurrent,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String month;
  final double amount;
  final bool isCurrent;

  const _MonthStat({
    required this.month,
    required this.amount,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          Formatters.currency(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrent ? theme.colorScheme.primary : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(month, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
