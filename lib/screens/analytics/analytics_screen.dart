/// Analytics view: period selector, total spending card, category breakdown bars,
/// month-over-month comparison.
///
/// All values are derived from [TransactionProvider]; no separate analytics
/// provider is needed because the computations are pure functions of the existing
/// transaction list. Selecting a period (Week / Month / Year) recomputes every
/// section in the same frame.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/viewmodels/category_breakdown.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Analytics screen with period selector, spending summary, category breakdown,
/// and month-over-month comparison — all computed from [TransactionProvider].
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  /// 0 = Week, 1 = Month, 2 = Year.
  int _selectedPeriod = 1;

  TransactionProvider? _txProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TransactionProvider>();
    if (_txProvider != provider) {
      _txProvider?.removeListener(_onProviderChanged);
      _txProvider = provider..addListener(_onProviderChanged);
      if (_txProvider!.transactions.isEmpty && !_txProvider!.isLoading) {
        _txProvider!.fetchTransactions();
      }
    }
  }

  @override
  void dispose() {
    _txProvider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    final error = _txProvider?.error;
    if (error != null && mounted) {
      _txProvider!.clearError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    }
  }

  // ---- period helpers -------------------------------------------------------

  /// Transactions that fall inside the selected period window.
  List<Transaction> _currentPeriod(List<Transaction> all) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0: // Week — last 7 full days
        final cutoff = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 7));
        return all.where((t) => !t.date.isBefore(cutoff)).toList();
      case 1: // Month — current calendar month
        return all
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList();
      case 2: // Year — current calendar year
        return all.where((t) => t.date.year == now.year).toList();
      default:
        return all;
    }
  }

  /// Transactions that fall inside the period immediately before the current one.
  List<Transaction> _previousPeriod(List<Transaction> all) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0: // Previous week
        final end = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 7));
        final start = end.subtract(const Duration(days: 7));
        return all
            .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
            .toList();
      case 1: // Previous calendar month
        final prev = DateTime(now.year, now.month - 1);
        return all
            .where(
              (t) => t.date.year == prev.year && t.date.month == prev.month,
            )
            .toList();
      case 2: // Previous calendar year
        return all.where((t) => t.date.year == now.year - 1).toList();
      default:
        return [];
    }
  }

  // ---- aggregation ----------------------------------------------------------

  double _totalExpenses(List<Transaction> txs) =>
      txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.absAmount);

  /// Builds [CategoryBreakdown] items sorted descending by amount.
  List<CategoryBreakdown> _buildBreakdown(List<Transaction> txs) {
    final expenses = txs.where((t) => t.isExpense);
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

  /// Returns spending totals for the last 3 calendar months.
  List<_MonthData> _last3Months(List<Transaction> all) {
    final now = DateTime.now();
    return List.generate(3, (i) {
      // i=0 → 2 months ago, i=1 → 1 month ago, i=2 → current month
      final month = DateTime(now.year, now.month - 2 + i);
      final spent = all
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (s, t) => s + t.absAmount);
      return _MonthData(
        label: DateFormat.MMM().format(month),
        amount: spent,
        isCurrent: i == 2,
      );
    });
  }

  // ---- comparison text/color -----------------------------------------------

  static const List<String> _periodLabels = ['week', 'month', 'year'];

  String _comparisonText(double current, double previous) {
    final label = _periodLabels[_selectedPeriod];
    if (previous == 0) return 'No data for the previous $label';
    final delta = current - previous;
    final pct = ((delta / previous) * 100).abs().toStringAsFixed(0);
    if (delta < -0.005) return '$pct% less than last $label';
    if (delta > 0.005) return '$pct% more than last $label';
    return 'Same as last $label';
  }

  Color _comparisonColor(double current, double previous, ThemeData theme) {
    if (previous == 0) return theme.colorScheme.onSurfaceVariant;
    return current <= previous ? AppColors.success : theme.colorScheme.error;
  }

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final all = provider.transactions;

    final current = _currentPeriod(all);
    final previous = _previousPeriod(all);

    final totalSpent = _totalExpenses(current);
    final prevSpent = _totalExpenses(previous);
    final breakdown = _buildBreakdown(current);
    final months = _last3Months(all);

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _PeriodSelector(
              selected: _selectedPeriod,
              onChanged: (v) => setState(() => _selectedPeriod = v),
            ),
            const SizedBox(height: AppSpacing.s20),
            _SpendingSummaryCard(
              spent: totalSpent,
              comparisonText: _comparisonText(totalSpent, prevSpent),
              comparisonColor: _comparisonColor(totalSpent, prevSpent, theme),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Spending by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (breakdown.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: Text(
                    'No expense transactions for this period.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...breakdown.map((c) => _CategoryBar(item: c)),
            const SizedBox(height: AppSpacing.md),
            _MonthComparisonCard(months: months),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting data class
// ---------------------------------------------------------------------------

/// Spending total for one month column in [_MonthComparisonCard].
class _MonthData {
  final String label;
  final double amount;
  final bool isCurrent;

  const _MonthData({
    required this.label,
    required this.amount,
    this.isCurrent = false,
  });
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Week / Month / Year segmented control.
class _PeriodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Week')),
        ButtonSegment(value: 1, label: Text('Month')),
        ButtonSegment(value: 2, label: Text('Year')),
      ],
      selected: {selected},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}

/// Card showing total spending and period-over-period comparison.
class _SpendingSummaryCard extends StatelessWidget {
  final double spent;
  final String comparisonText;
  final Color comparisonColor;

  const _SpendingSummaryCard({
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

/// One row: category name, proportional progress bar, amount.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(item.category, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusXs),
              child: LinearProgressIndicator(
                value: item.ratio,
                minHeight: AppSpacing.md,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: Categories.color(item.category),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          SizedBox(
            width: 60,
            child: Text(
              Formatters.currency(item.amount),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing spending for the last 3 calendar months.
class _MonthComparisonCard extends StatelessWidget {
  final List<_MonthData> months;

  const _MonthComparisonCard({required this.months});

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

/// Single month label and expense total in the month-comparison row.
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
