/// Budget overview: monthly summary card and category budget cards (spent vs limit).
///
/// Reads [BudgetProvider] for limits and [TransactionProvider] to compute
/// current-month spending per category. FAB opens an add-budget dialog;
/// tapping a [CategoryCard] opens an edit/delete dialog. The small "magic
/// wand" FAB regenerates budgets from history via the ML service.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_form_dialog.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/widgets/generate_budgets_fab.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/widgets/monthly_overview_card.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';
import 'package:ase485_capstone_finance_ml/widgets/category_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with ProviderErrorMixin<BudgetScreen> {
  /// One-shot guard for the "fetch on first arrival" pattern.
  bool _didTriggerInitialFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<BudgetProvider>();
    listenForErrors<BudgetProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    // build() calls context.watch, so every provider notification re-fires
    // didChangeDependencies. If we keyed the auto-fetch on `budgets.isEmpty`
    // a user with no budgets (or a failed request) would re-schedule
    // fetchBudgets() forever and strobe the screen.
    if (!_didTriggerInitialFetch) {
      _didTriggerInitialFetch = true;
      if (provider.budgets.isEmpty && !provider.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) provider.fetchBudgets();
        });
      }
    }
  }

  void _showAddDialog(Set<TransactionCategory> usedCategories) {
    if (usedCategories.length >= TransactionCategory.values.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All categories already have a budget.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => BudgetFormDialog(usedCategories: usedCategories),
    );
  }

  void _showEditDialog(Budget budget) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          BudgetFormDialog(initial: budget, usedCategories: const {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetProvider = context.watch<BudgetProvider>();
    final transactions = context.watch<TransactionProvider>().transactions;
    final budgets = budgetProvider.budgets;

    final totalBudget = budgets.fold(0.0, (s, b) => s + b.limitAmount);
    final totalSpent = budgets.fold(
      0.0,
      (s, b) => s + spentForCategory(b.category, transactions),
    );

    return LoadingOverlay(
      isLoading: budgetProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Budget')),
        body: budgets.isEmpty && !budgetProvider.isLoading
            ? const Center(
                child: Text('No budgets set up yet.\nTap + to add one.'),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  MonthlyOverviewCard(
                    month: DateTime.now(),
                    spent: totalSpent,
                    budget: totalBudget,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Category Budgets',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ...budgets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                      child: CategoryCard(
                        category: b.category,
                        spent: spentForCategory(b.category, transactions),
                        limit: b.limitAmount,
                        onTap: () => _showEditDialog(b),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GenerateBudgetsFab(),
            const SizedBox(height: AppSpacing.sm),
            FloatingActionButton(
              heroTag: 'budget_fab',
              onPressed: () =>
                  _showAddDialog(budgets.map((b) => b.category).toSet()),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
