/// Modal dialog for adding a new budget or editing/deleting an existing one.
///
/// Pass [initial] to pre-fill for edit mode. [usedCategories] excludes
/// already-budgeted categories from the add-mode dropdown.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';

class BudgetFormDialog extends StatefulWidget {
  final Budget? initial;
  final Set<TransactionCategory> usedCategories;

  const BudgetFormDialog({
    super.key,
    this.initial,
    required this.usedCategories,
  });

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  late TransactionCategory _category;
  late BudgetPeriod _period;
  bool _isSaving = false;

  bool get _isEditMode => widget.initial != null;

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
