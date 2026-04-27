/// Tests for spending aggregation helpers in [spending_helpers.dart].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';

void main() {
  final now = DateTime(2026, 4, 15);

  Transaction expense(TransactionCategory cat, double amount, DateTime date) =>
      Transaction(
        id: 'tx-${cat.name}-${date.day}',
        userId: 'u1',
        amount: -amount.abs(),
        category: cat,
        description: 'test',
        date: date,
      );

  Transaction income(double amount, DateTime date) => Transaction(
    id: 'income-${date.day}',
    userId: 'u1',
    amount: amount.abs(),
    category: TransactionCategory.other,
    description: 'salary',
    date: date,
  );

  // ---- spentForCategory ---------------------------------------------------

  group('spentForCategory', () {
    test('sums expenses for the given category in current month', () {
      final txs = [
        expense(TransactionCategory.food, 50, DateTime(2026, 4, 1)),
        expense(TransactionCategory.food, 30, DateTime(2026, 4, 10)),
        expense(TransactionCategory.bills, 100, DateTime(2026, 4, 5)),
      ];
      expect(spentForCategory(TransactionCategory.food, txs, now: now), 80);
    });

    test('ignores transactions from other months', () {
      final txs = [
        expense(TransactionCategory.food, 100, DateTime(2026, 3, 15)),
      ];
      expect(spentForCategory(TransactionCategory.food, txs, now: now), 0);
    });

    test('ignores income transactions', () {
      final txs = [income(500, DateTime(2026, 4, 1))];
      expect(spentForCategory(TransactionCategory.other, txs, now: now), 0);
    });
  });

  // ---- monthlyIncome / monthlyExpenses ------------------------------------

  group('monthlyIncome', () {
    test('sums income for current month only', () {
      final txs = [
        income(3000, DateTime(2026, 4, 1)),
        income(500, DateTime(2026, 4, 15)),
        income(1000, DateTime(2026, 3, 28)),
      ];
      expect(monthlyIncome(txs, now: now), 3500);
    });
  });

  group('monthlyExpenses', () {
    test('sums absolute expenses for current month only', () {
      final txs = [
        expense(TransactionCategory.food, 50, DateTime(2026, 4, 1)),
        expense(TransactionCategory.bills, 120, DateTime(2026, 4, 10)),
        expense(TransactionCategory.food, 80, DateTime(2026, 3, 28)),
      ];
      expect(monthlyExpenses(txs, now: now), 170);
    });
  });

  // ---- period filtering ---------------------------------------------------

  group('transactionsInCurrentPeriod', () {
    test('week returns last 7 days', () {
      final txs = [
        expense(TransactionCategory.food, 10, DateTime(2026, 4, 14)),
        expense(TransactionCategory.food, 10, DateTime(2026, 4, 8)),
        expense(TransactionCategory.food, 10, DateTime(2026, 4, 7)),
      ];
      final result = transactionsInCurrentPeriod(
        txs,
        AnalyticsPeriod.week,
        now: now,
      );
      // Cutoff is April 8 00:00; April 7 is before cutoff.
      expect(result, hasLength(2));
    });

    test('month returns current calendar month', () {
      final txs = [
        expense(TransactionCategory.food, 10, DateTime(2026, 4, 1)),
        expense(TransactionCategory.food, 10, DateTime(2026, 3, 31)),
      ];
      final result = transactionsInCurrentPeriod(
        txs,
        AnalyticsPeriod.month,
        now: now,
      );
      expect(result, hasLength(1));
    });

    test('year returns current calendar year', () {
      final txs = [
        expense(TransactionCategory.food, 10, DateTime(2026, 1, 1)),
        expense(TransactionCategory.food, 10, DateTime(2025, 12, 31)),
      ];
      final result = transactionsInCurrentPeriod(
        txs,
        AnalyticsPeriod.year,
        now: now,
      );
      expect(result, hasLength(1));
    });
  });

  group('transactionsInPreviousPeriod', () {
    test('previous month returns prior calendar month', () {
      final txs = [
        expense(TransactionCategory.food, 10, DateTime(2026, 3, 15)),
        expense(TransactionCategory.food, 10, DateTime(2026, 4, 1)),
      ];
      final result = transactionsInPreviousPeriod(
        txs,
        AnalyticsPeriod.month,
        now: now,
      );
      expect(result, hasLength(1));
      expect(result.first.date.month, 3);
    });
  });

  // ---- totalExpenses ------------------------------------------------------

  group('totalExpenses', () {
    test('sums only expense amounts', () {
      final txs = [
        expense(TransactionCategory.food, 50, DateTime(2026, 4, 1)),
        income(3000, DateTime(2026, 4, 1)),
        expense(TransactionCategory.bills, 100, DateTime(2026, 4, 5)),
      ];
      expect(totalExpenses(txs), 150);
    });
  });

  // ---- buildCategoryBreakdown ---------------------------------------------

  group('buildCategoryBreakdown', () {
    test('groups expenses by category with ratios', () {
      final txs = [
        expense(TransactionCategory.food, 60, DateTime(2026, 4, 1)),
        expense(TransactionCategory.food, 40, DateTime(2026, 4, 2)),
        expense(TransactionCategory.bills, 100, DateTime(2026, 4, 5)),
      ];
      final breakdown = buildCategoryBreakdown(txs);
      expect(breakdown, hasLength(2));
      expect(breakdown.first.category, 'Food');
      expect(breakdown.first.amount, 100);
      expect(breakdown.first.ratio, 0.5);
    });

    test('returns empty for no expenses', () {
      final txs = [income(1000, DateTime(2026, 4, 1))];
      expect(buildCategoryBreakdown(txs), isEmpty);
    });

    test('sorts descending by amount', () {
      final txs = [
        expense(TransactionCategory.food, 50, DateTime(2026, 4, 1)),
        expense(TransactionCategory.bills, 200, DateTime(2026, 4, 1)),
        expense(TransactionCategory.shopping, 100, DateTime(2026, 4, 1)),
      ];
      final breakdown = buildCategoryBreakdown(txs);
      expect(breakdown[0].category, 'Bills');
      expect(breakdown[1].category, 'Shopping');
      expect(breakdown[2].category, 'Food');
    });
  });

  // ---- last3MonthsSpending ------------------------------------------------

  group('last3MonthsSpending', () {
    test('returns 3 entries with current month last', () {
      final txs = [
        expense(TransactionCategory.food, 100, DateTime(2026, 2, 15)),
        expense(TransactionCategory.food, 200, DateTime(2026, 3, 15)),
        expense(TransactionCategory.food, 300, DateTime(2026, 4, 15)),
      ];
      final months = last3MonthsSpending(txs, now: now);
      expect(months, hasLength(3));
      expect(months[0].amount, 100);
      expect(months[1].amount, 200);
      expect(months[2].amount, 300);
      expect(months[2].isCurrent, isTrue);
      expect(months[0].isCurrent, isFalse);
    });
  });

  // ---- comparisonText -----------------------------------------------------

  group('comparisonText', () {
    test('shows "No data" when previous is zero', () {
      expect(
        comparisonText(100, 0, AnalyticsPeriod.month),
        'No data for the previous month',
      );
    });

    test('shows "less" when current is lower', () {
      expect(
        comparisonText(80, 100, AnalyticsPeriod.month),
        '20% less than last month',
      );
    });

    test('shows "more" when current is higher', () {
      expect(
        comparisonText(120, 100, AnalyticsPeriod.week),
        '20% more than last week',
      );
    });

    test('shows "Same" when approximately equal', () {
      expect(
        comparisonText(100, 100, AnalyticsPeriod.year),
        'Same as last year',
      );
    });
  });
}
