import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';
import 'package:ase485_capstone_finance_ml/utils/utils.dart';

/// Analytics dashboard screen showing spending insights.
/// 
/// Displays spending summary, category breakdown with visual bars,
/// and month-over-month comparison. Supports filtering by week, month, or year.
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

/// Period selector for filtering analytics by time range.
/// 
/// Allows users to switch between week, month, and year views.
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

/// Spending summary card showing total spending with comparison.
/// 
/// Displays the total spending amount for the selected period
/// with a comparison to the previous period.
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

/// Visual bar showing spending for a single category.
/// 
/// Displays category name, progress bar scaled by spending ratio,
/// and the actual spending amount.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item});

  /// The category breakdown data to display.
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

/// Month-over-month spending comparison card.
/// 
/// Shows spending amounts for the last three months to visualize
/// spending trends over time.
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

/// Individual month statistic display.
/// 
/// Shows spending amount for a single month with optional highlight
/// for the current month.
class _MonthStat extends StatelessWidget {
  /// Month abbreviation (e.g., "Jan", "Feb").
  final String month;
  
  /// Spending amount for this month.
  final double amount;
  
  /// Whether this is the current month (highlighted if true).
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
