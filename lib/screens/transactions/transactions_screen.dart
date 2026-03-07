/// Transactions list: month selector, category chips, and scrollable list with FAB to add.
///
/// Reads [TransactionProvider] for live data; month and category filter are local state.
/// [LoadingOverlay] covers the screen while fetching; errors surface as a [SnackBar].
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

/// Full-screen list of transactions with live provider data, month navigation,
/// category filter chips, loading overlay, and error SnackBar.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late DateTime _selectedMonth;
  TransactionCategory? _selectedCategory;

  /// Cached provider reference so we can attach/detach the listener safely.
  TransactionProvider? _provider;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TransactionProvider>();
    if (_provider != provider) {
      _provider?.removeListener(_onProviderChanged);
      _provider = provider..addListener(_onProviderChanged);
      if (_provider!.transactions.isEmpty && !_provider!.isLoading) {
        _provider!.fetchTransactions();
      }
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  /// Shows a SnackBar when [TransactionProvider.error] is set, then clears it.
  void _onProviderChanged() {
    final error = _provider?.error;
    if (error != null && mounted) {
      _provider!.clearError();
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

  void _previousMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
  });

  List<Transaction> _applyFilters(List<Transaction> all) => all
      .where(
        (t) =>
            t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month &&
            (_selectedCategory == null || t.category == _selectedCategory),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final filtered = _applyFilters(provider.transactions);

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {}, // TODO: advanced filter sheet
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {}, // TODO: search overlay
            ),
          ],
        ),
        body: Column(
          children: [
            _MonthSelector(
              month: _selectedMonth,
              onPrevious: _previousMonth,
              onNext: _nextMonth,
            ),
            _CategoryChips(
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: filtered.isEmpty && !provider.isLoading
                  ? const Center(child: Text('No transactions this month.'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) => TransactionTile(
                        transaction: filtered[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.addTransaction,
                          arguments: filtered[index],
                        ),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'transactions_fab',
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.addTransaction),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
    );
  }
}

/// Month navigation row (prev / label / next).
class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            DateFormat.yMMMM().format(month),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

/// Horizontal row of filter chips: "All" plus one per [TransactionCategory].
///
/// Tapping the already-selected category deselects it (falls back to "All").
class _CategoryChips extends StatelessWidget {
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory?> onSelected;

  const _CategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...TransactionCategory.values.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: FilterChip(
                label: Text(c.label),
                selected: selected == c,
                onSelected: (_) => onSelected(selected == c ? null : c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
