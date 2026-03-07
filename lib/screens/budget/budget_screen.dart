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
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';
import 'package:ase485_capstone_finance_ml/widgets/category_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Budget tab: monthly overview card, category budget cards, and add/edit dialogs.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetProvider? _budgetProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<BudgetProvider>();
    if (_budgetProvider != provider) {
      _budgetProvider?.removeListener(_onBudgetProviderChanged);
      _budgetProvider = provider..addListener(_onBudgetProviderChanged);
      if (_budgetProvider!.budgets.isEmpty && !_budgetProvider!.isLoading) {
        _budgetProvider!.fetchBudgets();
      }
    }
  }

  @override
  void dispose() {
    _budgetProvider?.removeListener(_onBudgetProviderChanged);
    super.dispose();
  }

  void _onBudgetProviderChanged() {
    final error = _budgetProvider?.error;
    if (error != null && mounted) {
      _budgetProvider!.clearError();
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

  /// Sums absolute expense amounts for [category] in the current calendar month.
  double _spentForCategory(
    TransactionCategory category,
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.isExpense &&
              t.category == category &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.absAmount);
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
      builder: (_) => _BudgetFormDialog(usedCategories: usedCategories),
    );
  }

  void _showEditDialog(Budget budget) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          _BudgetFormDialog(initial: budget, usedCategories: const {}),
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
      (s, b) => s + _spentForCategory(b.category, transactions),
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
                        spent: _spentForCategory(b.category, transactions),
                        limit: b.limitAmount,
                        onTap: () => _showEditDialog(b),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'budget_fab',
          onPressed: () =>
              _showAddDialog(budgets.map((b) => b.category).toSet()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MonthlyOverviewCard
// ---------------------------------------------------------------------------

/// Card showing current month, total spent vs total budget, progress bar, percent used.
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

// ---------------------------------------------------------------------------
// _BudgetFormDialog  (add + edit)
// ---------------------------------------------------------------------------

/// Modal dialog for adding a new budget or editing/deleting an existing one.
///
/// Pass [initial] to pre-fill for edit mode. [usedCategories] excludes
/// already-budgeted categories from the add-mode dropdown.
class _BudgetFormDialog extends StatefulWidget {
  final Budget? initial;
  final Set<TransactionCategory> usedCategories;

  const _BudgetFormDialog({this.initial, required this.usedCategories});

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  late TransactionCategory _category;
  late BudgetPeriod _period;
  bool _isSaving = false;

  bool get _isEditMode => widget.initial != null;

  /// In add mode, only show categories not yet budgeted.
  List<TransactionCategory> get _availableCategories => _isEditMode
      ? TransactionCategory.values
      : TransactionCategory.values
            .where((c) => !widget.usedCategories.contains(c))
            .toList();

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _limitController.text = t.limitAmount.toStringAsFixed(2);
      _category = t.category;
      _period = t.period;
    } else {
      _category = _availableCategories.first;
      _period = BudgetPeriod.monthly;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<BudgetProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final limit = double.parse(_limitController.text.trim());

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        await provider.updateBudget(
          widget.initial!.copyWith(
            category: _category,
            limitAmount: limit,
            period: _period,
          ),
        );
      } else {
        await provider.addBudget(
          Budget(
            id: '',
            userId: userId,
            category: _category,
            limitAmount: limit,
            period: _period,
            createdAt: DateTime.now(),
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final error = provider.error ?? 'Failed to save budget.';
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final provider = context.read<BudgetProvider>();
    setState(() => _isSaving = true);
    try {
      await provider.deleteBudget(widget.initial!.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final error = provider.error ?? 'Failed to delete budget.';
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Budget' : 'Add Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TransactionCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _availableCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              // Lock category in edit mode to avoid identity confusion.
              onChanged: _isEditMode
                  ? null
                  : (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Limit',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<BudgetPeriod>(
              initialValue: _period,
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
              ),
              items: BudgetPeriod.values
                  .map(
                    (p) =>
                        DropdownMenuItem(value: p, child: Text(p.displayLabel)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _period = v ?? _period),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditMode)
          TextButton(
            onPressed: _isSaving ? null : _delete,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
