/// Card showing total spending and period-over-period comparison text.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double spent;
  final String comparisonText;
  final Color comparisonColor;

  const SpendingSummaryCard({
    super.key,
    required this.spent,
    required this.comparisonText,
    required this.comparisonColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Spending', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Formatters.currency(spent),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              comparisonText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: comparisonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
