/// Analytics view: period selector, total spending card, category breakdown bars, month comparison.
///
/// Uses [sampleCategoryBreakdown] and sample totals; period selector not wired.
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Analytics screen with spending summary, category breakdown, and month-over-month comparison.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PeriodSelector(),
          const SizedBox(height: 20),
          const _SpendingSummaryCard(),
          const SizedBox(height: 16),
          Text(
            'Spending by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sampleCategoryBreakdown.map((c) => _CategoryBar(item: c)),
          const SizedBox(height: 16),
          const _MonthComparisonCard(),
        ],
      ),
    );
  }
}

/// Week / Month / Year segmented control (selection not wired).
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Week')),
        ButtonSegment(value: 1, label: Text('Month')),
        ButtonSegment(value: 2, label: Text('Year')),
      ],
      selected: const {1},
      onSelectionChanged: (_) {},
    );
  }
}

/// Card showing total spending and comparison text (e.g. "12% less than last month").
class _SpendingSummaryCard extends StatelessWidget {
  const _SpendingSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Spending', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              Formatters.currency(1820.50),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12% less than last month',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row: category name, progress bar by [CategoryBreakdown.ratio], amount.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item});

  /// Category and amount/ratio for this bar.
  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(item.category, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.ratio,
                minHeight: 16,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: Categories.color(item.category),
              ),
            ),
          ),
          const SizedBox(width: 12),
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

/// Card with "Month over Month" and a row of [_MonthStat] (e.g. Dec, Jan, Feb).
class _MonthComparisonCard extends StatelessWidget {
  const _MonthComparisonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month over Month', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MonthStat(month: 'Dec', amount: 2400),
                _MonthStat(month: 'Jan', amount: 2070),
                _MonthStat(month: 'Feb', amount: 1820, isCurrent: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Single month label and amount in the month-comparison row.
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
        const SizedBox(height: 4),
        Text(month, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
