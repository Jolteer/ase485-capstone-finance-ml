/// Transactions list: month selector, category chips, and scrollable list with FAB to add.
///
/// Reads [TransactionProvider] for live data; month and category filter are local state.
/// [LoadingOverlay] covers the screen while fetching; errors surface as a [SnackBar].
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/widgets/category_chips.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/widgets/month_selector.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

/// Full-screen list of transactions with live provider data, month navigation,
/// category filter chips, loading overlay, and error SnackBar.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with ProviderErrorMixin {
  late DateTime _selectedMonth;
  TransactionCategory? _selectedCategory;
  bool _didTriggerInitialFetch = false;

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
    listenForErrors<TransactionProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    // Defer to the next frame: runLoad notifies synchronously, and dispatching
    // notifications during the build that triggered didChangeDependencies
    // throws "setState() called during build" on web in debug mode.
    //
    // Gate the auto-fetch on a one-shot flag so a failed or empty response
    // can't re-trigger fetchTransactions() forever — build() uses
    // context.watch, so every provider notify re-runs didChangeDependencies.
    if (!_didTriggerInitialFetch) {
      _didTriggerInitialFetch = true;
      if (provider.transactions.isEmpty && !provider.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) provider.fetchTransactions();
        });
      }
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
            MonthSelector(
              month: _selectedMonth,
              onPrevious: _previousMonth,
              onNext: _nextMonth,
            ),
            CategoryChips(
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
