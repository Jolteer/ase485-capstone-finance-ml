/// Pure functions for transaction aggregation used across home, budget,
/// analytics, and alert screens.
///
/// Centralises logic that was previously duplicated in four widget files so
/// that every consumer computes the same numbers and the helpers are trivial
/// to unit-test.
library;

import 'package:intl/intl.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/models/category_breakdown.dart';

// ---------------------------------------------------------------------------
// Per-category helpers
// ---------------------------------------------------------------------------

/// Total absolute expense amount for [category] in the current calendar month.
double spentForCategory(
  TransactionCategory category,
  List<Transaction> transactions, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  return transactions
      .where(
        (t) =>
            t.isExpense &&
            t.category == category &&
            t.date.year == ref.year &&
            t.date.month == ref.month,
      )
      .fold(0.0, (sum, t) => sum + t.absAmount);
}

// ---------------------------------------------------------------------------
// Monthly summary (home dashboard)
// ---------------------------------------------------------------------------

/// Sum of positive (income) amounts for the current calendar month.
double monthlyIncome(List<Transaction> transactions, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  return transactions
      .where(
        (t) =>
            t.isIncome && t.date.year == ref.year && t.date.month == ref.month,
      )
      .fold(0.0, (s, t) => s + t.amount);
}

/// Sum of absolute expense amounts for the current calendar month.
double monthlyExpenses(List<Transaction> transactions, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  return transactions
      .where(
        (t) =>
            t.isExpense && t.date.year == ref.year && t.date.month == ref.month,
      )
      .fold(0.0, (s, t) => s + t.absAmount);
}

// ---------------------------------------------------------------------------
// Period filtering (analytics)
// ---------------------------------------------------------------------------

/// Enum matching the analytics period selector: Week (0), Month (1), Year (2).
enum AnalyticsPeriod { week, month, year }

/// Transactions that fall inside the *current* period window.
List<Transaction> transactionsInCurrentPeriod(
  List<Transaction> all,
  AnalyticsPeriod period, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  switch (period) {
    case AnalyticsPeriod.week:
      final cutoff = DateTime(
        ref.year,
        ref.month,
        ref.day,
      ).subtract(const Duration(days: 7));
      return all.where((t) => !t.date.isBefore(cutoff)).toList();
    case AnalyticsPeriod.month:
      return all
          .where((t) => t.date.year == ref.year && t.date.month == ref.month)
          .toList();
    case AnalyticsPeriod.year:
      return all.where((t) => t.date.year == ref.year).toList();
  }
}

/// Transactions that fall inside the period *immediately before* the current one.
List<Transaction> transactionsInPreviousPeriod(
  List<Transaction> all,
  AnalyticsPeriod period, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  switch (period) {
    case AnalyticsPeriod.week:
      final end = DateTime(
        ref.year,
        ref.month,
        ref.day,
      ).subtract(const Duration(days: 7));
      final start = end.subtract(const Duration(days: 7));
      return all
          .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
          .toList();
    case AnalyticsPeriod.month:
      final prev = DateTime(ref.year, ref.month - 1);
      return all
          .where((t) => t.date.year == prev.year && t.date.month == prev.month)
          .toList();
    case AnalyticsPeriod.year:
      return all.where((t) => t.date.year == ref.year - 1).toList();
  }
}

/// Total absolute expense amount from [transactions].
double totalExpenses(List<Transaction> transactions) =>
    transactions.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.absAmount);

// ---------------------------------------------------------------------------
// Category breakdown (analytics)
// ---------------------------------------------------------------------------

/// Builds [CategoryBreakdown] items sorted descending by amount.
List<CategoryBreakdown> buildCategoryBreakdown(List<Transaction> transactions) {
  final expenses = transactions.where((t) => t.isExpense);
  final byCategory = <String, double>{};
  for (final t in expenses) {
    byCategory[t.category.label] =
        (byCategory[t.category.label] ?? 0) + t.absAmount;
  }
  final total = byCategory.values.fold(0.0, (s, v) => s + v);
  if (total == 0) return [];

  return byCategory.entries
      .map((e) => CategoryBreakdown(e.key, e.value, e.value / total))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
}

// ---------------------------------------------------------------------------
// Month-over-month comparison (analytics)
// ---------------------------------------------------------------------------

/// Spending total for one month, used by [last3MonthsSpending].
class MonthSpending {
  final String label;
  final double amount;
  final bool isCurrent;

  const MonthSpending({
    required this.label,
    required this.amount,
    this.isCurrent = false,
  });
}

/// Returns spending totals for the last 3 calendar months (oldest first).
List<MonthSpending> last3MonthsSpending(
  List<Transaction> all, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  return List.generate(3, (i) {
    final month = DateTime(ref.year, ref.month - 2 + i);
    final spent = all
        .where(
          (t) =>
              t.isExpense &&
              t.date.year == month.year &&
              t.date.month == month.month,
        )
        .fold(0.0, (s, t) => s + t.absAmount);
    return MonthSpending(
      label: DateFormat.MMM().format(month),
      amount: spent,
      isCurrent: i == 2,
    );
  });
}

// ---------------------------------------------------------------------------
// Comparison text (analytics)
// ---------------------------------------------------------------------------

/// Human-readable comparison between current and previous period spending.
String comparisonText(double current, double previous, AnalyticsPeriod period) {
  const labels = ['week', 'month', 'year'];
  final label = labels[period.index];
  if (previous == 0) return 'No data for the previous $label';
  final delta = current - previous;
  final pct = ((delta / previous) * 100).abs().toStringAsFixed(0);
  if (delta < -0.005) return '$pct% less than last $label';
  if (delta > 0.005) return '$pct% more than last $label';
  return 'Same as last $label';
}
