/// Small card for a single summary metric: icon, title label, and value (e.g. Balance, Spent, Income).
///
/// Used on home dashboard [SummaryCards]. Optional [color] for the icon.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';

/// Summary metric card: icon, [title], and [value] text (e.g. "Balance", "\$4,250.00").
class SummaryCard extends StatelessWidget {
  /// Label (e.g. "Balance", "Spent", "Income").
  final String title;

  /// Formatted value (e.g. currency string).
  final String value;

  /// Icon for the metric (e.g. [Icons.account_balance_wallet]).
  final IconData icon;

  /// Optional icon color; defaults to theme primary.
  final Color? color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: AppSpacing.xl, color: iconColor),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
