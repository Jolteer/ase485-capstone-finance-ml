/// Analytics view: period selector, total spending card, category breakdown bars,
/// month-over-month comparison.
///
/// All values are derived from [TransactionProvider] via pure helpers in
/// [spending_helpers.dart]. Selecting a period (Week / Month / Year) recomputes
/// every section in the same frame.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/analytics/category_bar.dart';
import 'package:ase485_capstone_finance_ml/screens/analytics/month_comparison_card.dart';
import 'package:ase485_capstone_finance_ml/screens/analytics/spending_summary_card.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Analytics screen with period selector, spending summary, category breakdown,
/// and month-over-month comparison — all computed from [TransactionProvider].
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with ProviderErrorMixin {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TransactionProvider>();
    listenForErrors<TransactionProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    if (provider.transactions.isEmpty && !provider.isLoading) {
      provider.fetchTransactions();
    }
  }

  Color _comparisonColor(double current, double previous, ThemeData theme) {
    if (previous == 0) return theme.colorScheme.onSurfaceVariant;
    return current <= previous ? AppColors.success : theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final all = provider.transactions;

    final current = transactionsInCurrentPeriod(all, _selectedPeriod);
    final previous = transactionsInPreviousPeriod(all, _selectedPeriod);

    final totalSpent = totalExpenses(current);
    final prevSpent = totalExpenses(previous);
    final breakdown = buildCategoryBreakdown(current);
    final months = last3MonthsSpending(all);

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
            SpendingSummaryCard(
              spent: totalSpent,
              comparisonText: comparisonText(
                totalSpent,
                prevSpent,
                _selectedPeriod,
              ),
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
              ...breakdown.map((c) => CategoryBar(item: c)),
            const SizedBox(height: AppSpacing.md),
            MonthComparisonCard(months: months),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnalyticsPeriod>(
      segments: const [
        ButtonSegment(value: AnalyticsPeriod.week, label: Text('Week')),
        ButtonSegment(value: AnalyticsPeriod.month, label: Text('Month')),
        ButtonSegment(value: AnalyticsPeriod.year, label: Text('Year')),
      ],
      selected: {selected},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}
