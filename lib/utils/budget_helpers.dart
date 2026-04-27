/// Domain types and pure functions for budget alerts.
///
/// Extracted from `widgets/budget_alert_banner.dart` so that the alert
/// computation is testable independently of any Flutter widget.
library;

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

/// Severity of a budget alert.
enum AlertSeverity { warning, danger }

/// Single budget alert data.
class BudgetAlert {
  final TransactionCategory category;
  final double spent;
  final double limit;
  final AlertSeverity severity;

  const BudgetAlert({
    required this.category,
    required this.spent,
    required this.limit,
    required this.severity,
  });

  double get ratio => limit > 0 ? spent / limit : 0;
  double get overAmount => (spent - limit).clamp(0, double.maxFinite);
}

/// Computes budget alerts from budgets and transactions.
///
/// Returns alerts sorted by ratio (most severe first). A ratio >= 1.0 is
/// [AlertSeverity.danger]; >= 0.8 is [AlertSeverity.warning].
List<BudgetAlert> computeBudgetAlerts(
  List<Budget> budgets,
  List<Transaction> transactions, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  final alerts = <BudgetAlert>[];

  for (final budget in budgets) {
    final spent = transactions
        .where(
          (t) =>
              t.isExpense &&
              t.category == budget.category &&
              t.date.year == ref.year &&
              t.date.month == ref.month,
        )
        .fold(0.0, (sum, t) => sum + t.absAmount);

    final ratio = budget.limitAmount > 0 ? spent / budget.limitAmount : 0.0;

    if (ratio >= 1.0) {
      alerts.add(
        BudgetAlert(
          category: budget.category,
          spent: spent,
          limit: budget.limitAmount,
          severity: AlertSeverity.danger,
        ),
      );
    } else if (ratio >= 0.8) {
      alerts.add(
        BudgetAlert(
          category: budget.category,
          spent: spent,
          limit: budget.limitAmount,
          severity: AlertSeverity.warning,
        ),
      );
    }
  }

  alerts.sort((a, b) => b.ratio.compareTo(a.ratio));
  return alerts;
}
