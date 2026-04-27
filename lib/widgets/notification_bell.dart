/// AppBar notification bell icon with badge and alerts bottom sheet.
///
/// Shows a badge when budget alerts are active. Tapping opens a bottom sheet
/// listing all alerts with severity indicators.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/budget_helpers.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// AppBar icon that shows a badge when budget alerts are active.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final transactions = context.watch<TransactionProvider>().transactions;
    final alerts = computeBudgetAlerts(budgets, transactions);

    return IconButton(
      icon: Badge(
        isLabelVisible: alerts.isNotEmpty,
        label: Text('${alerts.length}'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () {
        if (alerts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No budget alerts right now.')),
          );
          return;
        }
        showModalBottomSheet<void>(
          context: context,
          builder: (_) => _AlertsSheet(alerts: alerts),
        );
      },
    );
  }
}

/// Bottom sheet listing all active budget alerts.
class _AlertsSheet extends StatelessWidget {
  final List<BudgetAlert> alerts;
  const _AlertsSheet({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Alerts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...alerts.map((a) {
              final isDanger = a.severity == AlertSeverity.danger;
              final color = isDanger
                  ? theme.colorScheme.error
                  : theme.colorScheme.tertiary;
              return ListTile(
                leading: Icon(
                  isDanger ? Icons.warning_rounded : Icons.info_outline,
                  color: color,
                ),
                title: Text(a.category.label),
                subtitle: Text(
                  '${Formatters.currency(a.spent)} / ${Formatters.currency(a.limit)} '
                  '(${(a.ratio * 100).toStringAsFixed(0)}%)',
                ),
                trailing: isDanger
                    ? Text(
                        'Over!',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
