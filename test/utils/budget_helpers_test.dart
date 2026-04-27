/// Tests for budget alert helpers in [budget_helpers.dart].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/budget_helpers.dart';

void main() {
  final now = DateTime(2026, 4, 15);

  Transaction expense(TransactionCategory cat, double amount) => Transaction(
    id: 'tx-${cat.name}',
    userId: 'u1',
    amount: -amount.abs(),
    category: cat,
    description: 'test',
    date: DateTime(now.year, now.month, 10),
  );

  Budget budget(TransactionCategory cat, double limit) => Budget(
    id: 'b-${cat.name}',
    userId: 'u1',
    category: cat,
    limitAmount: limit,
    period: BudgetPeriod.monthly,
    createdAt: DateTime(now.year, now.month, 1),
  );

  group('computeBudgetAlerts', () {
    test('returns empty when no budgets', () {
      final alerts = computeBudgetAlerts([], [
        expense(TransactionCategory.food, 100),
      ], now: now);
      expect(alerts, isEmpty);
    });

    test('returns empty when spending below 80%', () {
      final alerts = computeBudgetAlerts(
        [budget(TransactionCategory.food, 500)],
        [expense(TransactionCategory.food, 300)],
        now: now,
      );
      expect(alerts, isEmpty);
    });

    test('returns warning at 80%', () {
      final alerts = computeBudgetAlerts(
        [budget(TransactionCategory.food, 500)],
        [expense(TransactionCategory.food, 420)],
        now: now,
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.severity, AlertSeverity.warning);
    });

    test('returns danger at 100%', () {
      final alerts = computeBudgetAlerts(
        [budget(TransactionCategory.food, 500)],
        [expense(TransactionCategory.food, 550)],
        now: now,
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.severity, AlertSeverity.danger);
      expect(alerts.first.overAmount, 50);
    });

    test('sorts by ratio descending', () {
      final alerts = computeBudgetAlerts(
        [
          budget(TransactionCategory.food, 100),
          budget(TransactionCategory.entertainment, 100),
        ],
        [
          expense(TransactionCategory.food, 85),
          expense(TransactionCategory.entertainment, 110),
        ],
        now: now,
      );
      expect(alerts, hasLength(2));
      expect(alerts.first.category, TransactionCategory.entertainment);
    });

    test('ignores transactions from other months', () {
      final alerts = computeBudgetAlerts(
        [budget(TransactionCategory.food, 100)],
        [
          Transaction(
            id: 'old',
            userId: 'u1',
            amount: -200,
            category: TransactionCategory.food,
            description: 'old',
            date: DateTime(now.year, now.month - 1, 15),
          ),
        ],
        now: now,
      );
      expect(alerts, isEmpty);
    });
  });

  group('BudgetAlert', () {
    test('ratio computes correctly', () {
      const alert = BudgetAlert(
        category: TransactionCategory.food,
        spent: 80,
        limit: 100,
        severity: AlertSeverity.warning,
      );
      expect(alert.ratio, 0.8);
    });

    test('overAmount is clamped to zero when under budget', () {
      const alert = BudgetAlert(
        category: TransactionCategory.food,
        spent: 50,
        limit: 100,
        severity: AlertSeverity.warning,
      );
      expect(alert.overAmount, 0);
    });
  });
}
