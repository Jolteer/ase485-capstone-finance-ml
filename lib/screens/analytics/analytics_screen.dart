import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

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
          _PeriodSelector(),
          const SizedBox(height: 20),
          _SpendingSummaryCard(theme: theme),
          const SizedBox(height: 16),
          Text(
            'Spending by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._categoryBreakdown.map((c) => _CategoryBar(item: c, theme: theme)),
          const SizedBox(height: 16),
          _MonthComparisonCard(theme: theme),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
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

// ---------------------------------------------------------------------------
// Spending summary
// ---------------------------------------------------------------------------

class _SpendingSummaryCard extends StatelessWidget {
  const _SpendingSummaryCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category breakdown bar
// ---------------------------------------------------------------------------

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item, required this.theme});

  final _CatBreakdown item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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

// ---------------------------------------------------------------------------
// Month-over-month comparison
// ---------------------------------------------------------------------------

class _MonthComparisonCard extends StatelessWidget {
  const _MonthComparisonCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _CatBreakdown {
  final String category;
  final double amount;
  final double ratio;
  const _CatBreakdown(this.category, this.amount, this.ratio);
}

const _categoryBreakdown = [
  _CatBreakdown('Food', 420, 0.84),
  _CatBreakdown('Bills', 650, 1.0),
  _CatBreakdown('Shopping', 210, 0.42),
  _CatBreakdown('Transportation', 160, 0.32),
  _CatBreakdown('Entertainment', 180, 0.36),
  _CatBreakdown('Healthcare', 80, 0.16),
  _CatBreakdown('Education', 50, 0.10),
];
