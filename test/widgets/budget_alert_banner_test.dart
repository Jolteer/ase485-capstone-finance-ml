/// Tests for [BudgetAlertBanner] and [computeBudgetAlerts].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/budget_helpers.dart';

void main() {
  final now = DateTime.now();

  Transaction _expense(TransactionCategory cat, double amount) => Transaction(
    id: 'tx-${cat.name}',
    userId: 'u1',
    amount: -amount.abs(),
    category: cat,
    description: 'test',
    date: DateTime(now.year, now.month, 15),
  );

  Budget _budget(TransactionCategory cat, double limit) => Budget(
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
        _expense(TransactionCategory.food, 100),
      ]);
      expect(alerts, isEmpty);
    });

    test('returns empty when spending is below 80%', () {
      final alerts = computeBudgetAlerts(
        [_budget(TransactionCategory.food, 500)],
        [_expense(TransactionCategory.food, 300)],
      );
      expect(alerts, isEmpty);
    });

    test('returns warning at 80%', () {
      final alerts = computeBudgetAlerts(
        [_budget(TransactionCategory.food, 500)],
        [_expense(TransactionCategory.food, 420)],
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.severity, AlertSeverity.warning);
    });

    test('returns danger at 100%', () {
      final alerts = computeBudgetAlerts(
        [_budget(TransactionCategory.food, 500)],
        [_expense(TransactionCategory.food, 550)],
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.severity, AlertSeverity.danger);
      expect(alerts.first.overAmount, 50);
    });

    test('sorts by ratio descending', () {
      final alerts = computeBudgetAlerts(
        [
          _budget(TransactionCategory.food, 100),
          _budget(TransactionCategory.entertainment, 100),
        ],
        [
          _expense(TransactionCategory.food, 85),
          _expense(TransactionCategory.entertainment, 110),
        ],
      );
      expect(alerts, hasLength(2));
      expect(alerts.first.category, TransactionCategory.entertainment);
    });

    test('ignores transactions from other months', () {
      final alerts = computeBudgetAlerts(
        [_budget(TransactionCategory.food, 100)],
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
      );
      expect(alerts, isEmpty);
    });
  });
}
