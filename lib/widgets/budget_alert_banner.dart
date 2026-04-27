/// Banner widget that warns when spending approaches or exceeds budget limits.
///
/// Uses [computeBudgetAlerts] from [budget_helpers.dart] to determine which
/// categories need alerts, then renders warning/danger cards.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/budget_helpers.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Displays budget alert banners. Renders nothing when no alerts are active.
class BudgetAlertBanner extends StatelessWidget {
  const BudgetAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final transactions = context.watch<TransactionProvider>().transactions;
    final alerts = computeBudgetAlerts(budgets, transactions);

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(children: alerts.map((a) => _AlertCard(alert: a)).toList());
  }
}

class _AlertCard extends StatelessWidget {
  final BudgetAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDanger = alert.severity == AlertSeverity.danger;
    final bgColor = isDanger
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.tertiaryContainer;
    final fgColor = isDanger
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onTertiaryContainer;
    final icon = isDanger ? Icons.warning_rounded : Icons.info_outline;
    final pct = (alert.ratio * 100).toStringAsFixed(0);

    final message = isDanger
        ? '${alert.category.label} is over budget by '
              '${Formatters.currency(alert.overAmount)}!'
        : '${alert.category.label} is at $pct% of budget '
              '(${Formatters.currency(alert.spent)} / '
              '${Formatters.currency(alert.limit)})';

    return Card(
      color: bgColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
