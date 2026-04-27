/// Budget overview: monthly summary card and category budget cards (spent vs limit).
///
/// Reads [BudgetProvider] for limits and [TransactionProvider] to compute
/// current-month spending per category. FAB opens an add-budget dialog;
/// tapping a [CategoryCard] opens an edit/delete dialog.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_form_dialog.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';
import 'package:ase485_capstone_finance_ml/widgets/category_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Budget tab: monthly overview card, category budget cards, and add/edit dialogs.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with ProviderErrorMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<BudgetProvider>();
    listenForErrors<BudgetProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    if (provider.budgets.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) provider.fetchBudgets();
      });
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
                  _MonthlyOverviewCard(
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
            FloatingActionButton.small(
              heroTag: 'budget_generate_fab',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Generate Budgets'),
                    content: const Text(
                      'This will analyse your spending history and replace '
                      'your current budgets with ML-generated suggestions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<BudgetProvider>().generateBudgets();
                }
              },
              child: const Icon(Icons.auto_awesome),
            ),
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

// ---------------------------------------------------------------------------
// _MonthlyOverviewCard
// ---------------------------------------------------------------------------

class _MonthlyOverviewCard extends StatelessWidget {
  final DateTime month;
  final double spent;
  final double budget;

  const _MonthlyOverviewCard({
    required this.month,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              DateFormat.yMMMM().format(month),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${Formatters.currency(spent)} / ${Formatters.currency(budget)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: AppSpacing.s10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}% of monthly budget used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
